import 'package:dio/dio.dart';

import '../models/comment.dart';

/// Mengambil dan mengubah respons endpoint komentar menjadi model aplikasi.
class CommentRepository {
  /// Menerima instance Dio agar repository dapat digunakan ulang dan diuji.
  CommentRepository(this._dio);

  final Dio _dio;

  /// Mengambil komentar untuk post tertentu.
  /// Timeout diatur terpusat di createDio(), bukan di sini.
  Future<List<Comment>> fetchComments(int postId) async {
    final response = await _dio.get<List>(
      '/comments',
      queryParameters: {'postId': postId},
    );

    // Abaikan item yang bukan objek JSON dan ubah item valid menjadi Comment.
    final data = response.data ?? const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(Comment.fromJson)
        .toList();
  }
}