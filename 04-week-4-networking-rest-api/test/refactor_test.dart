import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/post.dart';
import 'package:week4_api/data/network_errors.dart';
import 'package:week4_api/data/providers.dart';
import 'package:week4_api/data/repositories/post_repository.dart';
import 'package:week4_api/router.dart';
import 'package:week4_api/widgets/post_tile.dart';

class _FakeRepo extends PostRepository {
  _FakeRepo(this.posts) : super(Dio());

  final List<Post> posts;
  int detailCalls = 0;

  @override
  Future<List<Post>> fetchPosts() async => posts;

  @override
  Future<Post> fetchPostById(int id) async {
    detailCalls++;
    return posts.firstWhere((p) => p.id == id);
  }
}

List<Post> _makePosts(int n) => List.generate(
      n,
      (i) => Post(
        userId: 1,
        id: i + 1,
        title: 'Judul ${i + 1}',
        body: 'Isi ${i + 1}',
      ),
    );

Widget _buildApp(_FakeRepo repo, {String initialLocation = '/'}) {
  return ProviderScope(
    overrides: [postRepositoryProvider.overrideWithValue(repo)],
    child: MaterialApp.router(
      routerConfig: createRouter(initialLocation: initialLocation),
    ),
  );
}

DioException _dioError(DioExceptionType type, {int? status}) {
  final options = RequestOptions(path: '/');
  return DioException(
    requestOptions: options,
    type: type,
    response: status == null
        ? null
        : Response(requestOptions: options, statusCode: status),
  );
}

void main() {
  group('friendlyErrorMessage', () {
    test('connectionError', () {
      expect(
        friendlyErrorMessage(_dioError(DioExceptionType.connectionError)),
        'Tidak dapat terhubung ke server. Periksa internet Anda.',
      );
    });

    test('404', () {
      expect(
        friendlyErrorMessage(
            _dioError(DioExceptionType.badResponse, status: 404)),
        'Data tidak ditemukan (404).',
      );
    });

    test('error non-Dio tidak membocorkan pesan teknis', () {
      expect(
        friendlyErrorMessage(StateError('rahasia')),
        isNot(contains('rahasia')),
      );
    });
  });

  testWidgets('PostTile menampilkan data dan memanggil onTap',
      (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PostTile(
            post: const Post(userId: 1, id: 7, title: 'T', body: 'B'),
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('7'), findsOneWidget);
    expect(find.text('T'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);

    await tester.tap(find.byType(PostTile));
    expect(tapped, isTrue);
  });

  testWidgets('detail memakai data list yang sudah dimuat', (tester) async {
    final repo = _FakeRepo(_makePosts(10));
    await tester.pumpWidget(_buildApp(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Judul 2'));
    await tester.pumpAndSettle();

    expect(find.text('Post #2'), findsOneWidget);
    expect(repo.detailCalls, 0); // tidak ada request detail
  });

  testWidgets('deep link /post/5 mengambil lewat repository',
      (tester) async {
    final repo = _FakeRepo(_makePosts(10));
    await tester.pumpWidget(_buildApp(repo, initialLocation: '/post/5'));
    await tester.pumpAndSettle();

    expect(find.text('Post #5'), findsOneWidget);
    expect(find.text('Judul 5'), findsOneWidget);
    expect(repo.detailCalls, 1);
  });

  testWidgets('ID tidak valid menampilkan pesan', (tester) async {
    final repo = _FakeRepo(_makePosts(3));
    await tester.pumpWidget(_buildApp(repo, initialLocation: '/post/abc'));
    await tester.pumpAndSettle();

    expect(find.text('ID post tidak valid.'), findsOneWidget);
  });
}