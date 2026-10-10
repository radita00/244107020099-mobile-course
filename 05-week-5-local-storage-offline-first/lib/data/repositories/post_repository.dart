import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';
import '../local/db.dart';
import '../post.dart';

class PostRepository {
  PostRepository({Dio? dio, Future<Database> Function()? openDb})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'https://jsonplaceholder.typicode.com',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            )),
        _openDb = openDb ?? openNotesDb;

  final Dio _dio;
  final Future<Database> Function() _openDb;

  /// Baca dari tabel cached_posts.
  Future<List<Post>> readCachedPosts() async {
    final db = await _openDb();
    final rows = await db.query('cached_posts', orderBy: 'id ASC');
    return rows
        .map((r) => Post.fromJson(
            jsonDecode(r['payload'] as String) as Map<String, dynamic>))
        .toList();
  }

  /// Ambil dari jaringan (GET /posts).
  Future<List<Post>> fetchRemote() async {
    final res = await _dio.get<List<dynamic>>('/posts');
    return (res.data ?? [])
        .map((e) => Post.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Simpan hasil jaringan ke cache (timpa isi lama).
  Future<void> saveToCache(List<Post> posts) async {
    final db = await _openDb();
    final now = DateTime.now().toIso8601String();
    await db.transaction((txn) async {
      await txn.delete('cached_posts');
      final batch = txn.batch();
      for (final p in posts) {
        batch.insert(
          'cached_posts',
          {'id': p.id, 'payload': jsonEncode(p.toJson()), 'cached_at': now},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }
}