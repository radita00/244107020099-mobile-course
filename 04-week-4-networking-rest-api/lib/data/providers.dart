import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'api_client.dart';
import 'models/comment.dart';
import 'models/post.dart';
import 'repositories/comment_repository.dart';
import 'repositories/post_repository.dart';

final dioProvider = Provider<Dio>((ref) => createDio());

final postRepositoryProvider = Provider<PostRepository>(
  (ref) => PostRepository(ref.watch(dioProvider)),
);

// Repository provider berbagi client Dio tetapi menjaga lapisan akses data tersendiri.
final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => CommentRepository(ref.watch(dioProvider)),
);

/// Quản lý trạng thái async danh sách komentar milik một post.
class CommentListNotifier extends AsyncNotifier<List<Comment>> {
  /// Menyimpan postId yang dipasangkan oleh provider family.
  CommentListNotifier(this.postId);

  final int postId;

  /// Memuat komentar; exception diteruskan agar Riverpod membentuk AsyncError.
  @override
  Future<List<Comment>> build() {
    // Exception yang tidak ditangkap akan otomatis menjadi AsyncError oleh Riverpod.
    return ref.watch(commentRepositoryProvider).fetchComments(postId);
  }
}

/// Setiap nilai postId memiliki state komentar yang terpisah.
final commentListProvider =
    AsyncNotifierProvider.family<CommentListNotifier, List<Comment>, int>(
  CommentListNotifier.new,
  // Menonaktifkan retry otomatis agar state error tidak mengulang permintaan sendiri.
  retry: (retryCount, error) => null,
);

class PostListNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    // Exception dari repository otomatis menjadi AsyncError.
    final repository = ref.watch(postRepositoryProvider);
    return repository.fetchPosts();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(postRepositoryProvider);
      state = AsyncData(await repository.fetchPosts());
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final postListProvider =
    AsyncNotifierProvider<PostListNotifier, List<Post>>(
        PostListNotifier.new,
        // Nonaktifkan retry otomatis Riverpod 3 agar error langsung final.
        retry: (retryCount, error) => null);

/// Helper testing: baca state pertama yang bukan loading.
Future<List<Post>> readPostsOnce(ProviderContainer container) {
  final completer = Completer<List<Post>>();
  final sub = container.listen<AsyncValue<List<Post>>>(
    postListProvider,
    (previous, next) {
      if (next.isLoading || completer.isCompleted) return;
      next.whenData(completer.complete);
      if (next.hasError) {
        completer.completeError(
          next.error ?? StateError('unknown error'),
          next.stackTrace ?? StackTrace.empty,
        );
      }
    },
    fireImmediately: true,
  );
  return completer.future.whenComplete(sub.close);
}

Future<Object?> readPostsErrorOnce(ProviderContainer container) {
  final completer = Completer<Object?>();
  final sub = container.listen<AsyncValue<List<Post>>>(
    postListProvider,
    (previous, next) {
      if (next.isLoading || completer.isCompleted) return;
      completer.complete(next.error);
    },
    fireImmediately: true,
  );
  return completer.future.whenComplete(sub.close);
}