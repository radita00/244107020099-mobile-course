import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';

class PostsPage extends ConsumerWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postsProvider);
    final status = ref.watch(postsStatusProvider);
    final offline = ref.watch(forceOfflineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts (cache-first)'),
        actions: [
          if (offline) const Icon(Icons.cloud_off),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(postsProvider.notifier).refreshPostsInBackground(),
          ),
        ],
      ),
      body: Column(
        children: [
          if (status.isNotEmpty)
            Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.secondaryContainer,
              padding: const EdgeInsets.all(8),
              child: Text(status),
            ),
          Expanded(
            child: posts.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (list) => list.isEmpty
                  ? const Center(
                      child: Text('Cache kosong. Nyalakan internet lalu refresh.'))
                  : ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (_, i) => ListTile(
                        leading: CircleAvatar(child: Text('${list[i].id}')),
                        title: Text(list[i].title,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(list[i].body,
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}