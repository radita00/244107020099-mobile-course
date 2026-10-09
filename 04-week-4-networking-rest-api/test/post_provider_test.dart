import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/post.dart';
import 'package:week4_api/data/paged_posts.dart';
import 'package:week4_api/data/providers.dart';
import 'package:week4_api/data/repositories/post_repository.dart';

/// Repository palsu: tanpa HTTP, hanya data buatan atau error yang diatur test.
class _FakeRepo extends PostRepository {
  _FakeRepo({this.error, this.totalPosts = 25}) : super(Dio());

  final Object? error;
  final int totalPosts;
  int pageCalls = 0;

  @override
  Future<List<Post>> fetchPosts() async {
    if (error != null) throw error!;
    return List.generate(
      3,
      (i) => Post(userId: 1, id: i + 1, title: 'T${i + 1}', body: 'B${i + 1}'),
    );
  }

  @override
  Future<List<Post>> fetchPostsPage({
    required int page,
    int limit = 10,
  }) async {
    pageCalls++;
    if (error != null) throw error!;
    final start = (page - 1) * limit;
    if (start >= totalPosts) return [];
    final end = min(start + limit, totalPosts);
    return List.generate(
      end - start,
      (i) => Post(
        userId: 1,
        id: start + i + 1,
        title: 'T${start + i + 1}',
        body: 'B${start + i + 1}',
      ),
    );
  }
}

ProviderContainer _makeContainer(_FakeRepo repo) {
  final container = ProviderContainer(
    overrides: [postRepositoryProvider.overrideWithValue(repo)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('postListProvider', () {
    test('sukses: mengeluarkan data dari repository', () async {
      final container = _makeContainer(_FakeRepo());

      final posts = await readPostsOnce(container);

      expect(posts.length, 3);
      expect(posts.first.title, 'T1');
    });

    test('error: exception repository menjadi AsyncError', () async {
      final error = DioException(
        requestOptions: RequestOptions(path: '/posts'),
        type: DioExceptionType.connectionError,
      );
      final container = _makeContainer(_FakeRepo(error: error));

      final result = await readPostsErrorOnce(container);

      expect(result, isA<DioException>());
    });
  });

  group('pagedPostsProvider', () {
    test('memuat halaman 1 (10 item) saat pertama dibaca', () async {
      final repo = _FakeRepo();
      final container = _makeContainer(repo);

      container.read(pagedPostsProvider); // memicu build()
      await pumpEventQueue();

      final state = container.read(pagedPostsProvider);
      expect(state.items.length, 10);
      expect(state.page, 1);
      expect(state.hasMore, isTrue);
      expect(repo.pageCalls, 1);
    });

    test('guard: dua loadNextPage berurutan hanya 1 request', () async {
      final repo = _FakeRepo();
      final container = _makeContainer(repo);
      container.read(pagedPostsProvider);
      await pumpEventQueue();

      final notifier = container.read(pagedPostsProvider.notifier);
      await Future.wait([notifier.loadNextPage(), notifier.loadNextPage()]);

      final state = container.read(pagedPostsProvider);
      expect(state.page, 2);
      expect(state.items.length, 20);
      expect(repo.pageCalls, 2); // halaman 1 + halaman 2, bukan 3
    });

    test('berhenti saat data habis (hasMore = false)', () async {
      final repo = _FakeRepo(totalPosts: 25);
      final container = _makeContainer(repo);
      container.read(pagedPostsProvider);
      await pumpEventQueue();

      final notifier = container.read(pagedPostsProvider.notifier);
      await notifier.loadNextPage(); // halaman 2 (10 item)
      await notifier.loadNextPage(); // halaman 3 (5 item) -> habis
      await notifier.loadNextPage(); // tidak boleh request lagi

      final state = container.read(pagedPostsProvider);
      expect(state.items.length, 25);
      expect(state.hasMore, isFalse);
      expect(repo.pageCalls, 3);
    });

    test('error halaman 1 disimpan di state tanpa crash', () async {
      final repo = _FakeRepo(error: StateError('gagal'));
      final container = _makeContainer(repo);

      container.read(pagedPostsProvider);
      await pumpEventQueue();

      final state = container.read(pagedPostsProvider);
      expect(state.error, isA<StateError>());
      expect(state.items, isEmpty);
    });
  });
}