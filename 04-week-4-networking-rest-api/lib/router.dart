import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'pages/paged_post_page.dart';
import 'pages/post_detail_page.dart';
import 'pages/post_list_page.dart';

/// Dibuat lewat fungsi agar test bisa memulai dari lokasi mana pun.
GoRouter createRouter({String initialLocation = '/'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const PostListPage(),
      ),
      GoRoute(
        path: '/paged',
        builder: (context, state) => const PagedPostPage(),
      ),
      GoRoute(
        path: '/post/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Detail Post')),
              body: const Center(child: Text('ID post tidak valid.')),
            );
          }
          return PostDetailPage(postId: id);
        },
      ),
    ],
  );
}