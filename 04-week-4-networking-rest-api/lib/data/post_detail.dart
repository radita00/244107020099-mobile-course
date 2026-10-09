import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/post.dart';
import 'paged_posts.dart';
import 'providers.dart';

/// State detail satu post: ambil dari list yang sudah dimuat bila ada,
/// jika tidak (misalnya deep link) ambil lewat repository.
class PostDetailNotifier extends AsyncNotifier<Post> {
  PostDetailNotifier(this.postId);

  final int postId;

  @override
  Future<Post> build() async {
    final cached = _findLoadedPost();
    if (cached != null) return cached;
    return ref.watch(postRepositoryProvider).fetchPostById(postId);
  }

  Post? _findLoadedPost() {
    if (ref.exists(postListProvider)) {
      final listState = ref.read(postListProvider);
      if (listState.hasValue) {
        final found = _firstWithId(listState.requireValue);
        if (found != null) return found;
      }
    }
    if (ref.exists(pagedPostsProvider)) {
      return _firstWithId(ref.read(pagedPostsProvider).items);
    }
    return null;
  }

  Post? _firstWithId(Iterable<Post> posts) {
    for (final post in posts) {
      if (post.id == postId) return post;
    }
    return null;
  }
}

final postDetailProvider =
    AsyncNotifierProvider.family<PostDetailNotifier, Post, int>(
  PostDetailNotifier.new,
  // Nonaktifkan retry otomatis agar error langsung final.
  retry: (retryCount, error) => null,
);