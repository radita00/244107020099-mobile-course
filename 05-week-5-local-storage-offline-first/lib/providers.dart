import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/local/note.dart';
import 'data/repositories/note_repository.dart';
import 'data/sync.dart';
import 'data/post.dart';
import 'data/repositories/post_repository.dart';

// ---- Force offline (simulasi deterministik) ----
class ForceOfflineNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool value) => state = value;
}
// ---- Posts (cache-first) ----
final postRepositoryProvider = Provider((ref) => PostRepository());

/// Keterangan sumber data terakhir, untuk observasi saat demo.
class PostsStatusNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String v) => state = v;
}

final postsStatusProvider =
    NotifierProvider<PostsStatusNotifier, String>(PostsStatusNotifier.new);

final postsProvider =
    AsyncNotifierProvider<PostsNotifier, List<Post>>(PostsNotifier.new);

class PostsNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() => loadPostsCacheFirst();

  Future<List<Post>> loadPostsCacheFirst() async {
    final repo = ref.read(postRepositoryProvider);
    final cached = await repo.readCachedPosts(); // dari tabel cached_posts

    // 1. Segera kembalikan cache agar UI tidak blank saat offline.
    // 2. Di background: fetch Dio -> simpan ke cached_posts -> perbarui state.
    refreshPostsInBackground();
    return cached;
  }

  Future<void> refreshPostsInBackground() async {
    final repo = ref.read(postRepositoryProvider);
    if (ref.read(forceOfflineProvider)) {
      ref.read(postsStatusProvider.notifier).set('Offline: menampilkan cache');
      return;
    }
    try {
      final fresh = await repo.fetchRemote();
      await repo.saveToCache(fresh);
      state = AsyncData(fresh); // memperbarui UI dengan data terbaru
      ref.read(postsStatusProvider.notifier).set('Diperbarui dari jaringan');
    } catch (_) {
      // Gagal jaringan: cache tetap tampil.
      ref
          .read(postsStatusProvider.notifier)
          .set('Jaringan gagal: menampilkan cache');
    }
  }
}

final forceOfflineProvider =
    NotifierProvider<ForceOfflineNotifier, bool>(ForceOfflineNotifier.new);

// ---- Catatan ----
final noteRepositoryProvider = Provider((ref) => NoteRepository());

final notesProvider =
    AsyncNotifierProvider<NotesNotifier, List<Note>>(NotesNotifier.new);

class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() => ref.watch(noteRepositoryProvider).fetchNotes();

  Future<void> add(String title, String body) async {
    await ref.read(noteRepositoryProvider).addNote(title: title, body: body);
    ref.invalidateSelf();
    await future;
  }

  Future<void> remove(int id) async {
    await ref.read(noteRepositoryProvider).deleteNote(id);
    ref.invalidateSelf();
    await future;
  }

  /// Mengembalikan jumlah catatan yang tersinkron, atau null bila sedang offline.
  Future<int?> sync() async {
    if (ref.read(forceOfflineProvider)) return null;
    final count = await syncNotes(ref.read(noteRepositoryProvider));
    ref.invalidateSelf();
    await future;
    return count;
  }
}

/// Badge antrean sync: jumlah catatan dirty.
final dirtyCountProvider = FutureProvider<int>((ref) async {
  ref.watch(notesProvider); // hitung ulang tiap daftar catatan berubah
  return ref.watch(noteRepositoryProvider).countDirty();
});