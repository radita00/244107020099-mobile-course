import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/post.dart';
import 'package:week4_api/data/providers.dart';
import 'package:week4_api/data/repositories/post_repository.dart';
import 'package:week4_api/pages/paged_post_page.dart';
import 'package:week4_api/pages/post_list_page.dart';

/// Repository palsu: tidak melakukan HTTP, hanya mengembalikan data/error.
class FakePostRepository extends PostRepository {
  FakePostRepository({this.posts = const [], this.error}) : super(Dio());

  final List<Post> posts;
  final Object? error;

  @override
  Future<List<Post>> fetchPosts() async {
    if (error != null) throw error!;
    return posts;
  }

  @override
  Future<List<Post>> fetchPostsPage({
    required int page,
    int limit = 10,
  }) async {
    if (error != null) throw error!;
    return posts;
  }
}

List<Post> makePosts(int n) => List.generate(
      n,
      (i) => Post(
        userId: 1,
        id: i + 1,
        title: 'Judul ${i + 1}',
        body: 'Isi ${i + 1}',
      ),
    );

Widget buildApp(Widget home, FakePostRepository repo) {
  return ProviderScope(
    overrides: [postRepositoryProvider.overrideWithValue(repo)],
    child: MaterialApp(home: home),
  );
}

void main() {
  testWidgets('PostListPage menampilkan daftar post', (tester) async {
    await tester.pumpWidget(
      buildApp(const PostListPage(), FakePostRepository(posts: makePosts(3))),
    );
    await tester.pumpAndSettle();

    expect(find.text('Judul 1'), findsOneWidget);
    expect(find.text('Judul 3'), findsOneWidget);
  });

  testWidgets('PostListPage menampilkan pesan ramah saat error',
      (tester) async {
    final error = DioException(
      requestOptions: RequestOptions(path: '/posts'),
      type: DioExceptionType.connectionError,
    );
    await tester.pumpWidget(
      buildApp(const PostListPage(), FakePostRepository(error: error)),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Tidak dapat terhubung ke server. Periksa internet Anda.'),
      findsOneWidget,
    );
    expect(find.text('Coba lagi'), findsOneWidget);
  });

  testWidgets('PostListPage menampilkan empty state', (tester) async {
    await tester.pumpWidget(
      buildApp(const PostListPage(), FakePostRepository(posts: const [])),
    );
    await tester.pumpAndSettle();

    expect(find.text('Belum ada data dari server.'), findsOneWidget);
  });

  testWidgets('PagedPostPage menampilkan data dan penanda akhir',
      (tester) async {
    // 3 item (< 10) berarti hasMore = false, jadi tidak ada spinner abadi.
    await tester.pumpWidget(
      buildApp(const PagedPostPage(), FakePostRepository(posts: makePosts(3))),
    );
    await tester.pumpAndSettle();

    expect(find.text('Judul 1'), findsOneWidget);
    expect(find.text('Semua data termuat.'), findsOneWidget);
  });
}