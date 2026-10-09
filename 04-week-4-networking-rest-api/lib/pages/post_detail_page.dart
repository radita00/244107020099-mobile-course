import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/network_errors.dart';
import '../data/post_detail.dart';

class PostDetailPage extends ConsumerWidget {
  const PostDetailPage({super.key, required this.postId});

  final int postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(postDetailProvider(postId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Post'),
        // Saat dibuka langsung (deep link) tidak ada halaman sebelumnya,
        // sehingga tombol kembali diganti tombol ke beranda.
        leading: context.canPop()
            ? null
            : IconButton(
                icon: const Icon(Icons.home),
                onPressed: () => context.go('/'),
              ),
      ),
      body: postAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(friendlyErrorMessage(err), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(postDetailProvider(postId)),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
        data: (post) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Post #${post.id}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Text(
                post.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                post.body,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}