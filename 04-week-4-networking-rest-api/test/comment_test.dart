import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/comment.dart';
import 'package:week4_api/data/models/post.dart';

void main() {
  group('Comment.fromJson', () {
    // Happy path: semua field valid.
    test('membaca payload lengkap dengan benar', () {
      final comment = Comment.fromJson(const {
        'postId': 1,
        'id': 5,
        'name': 'Budi',
        'email': 'budi@mail.com',
        'body': 'Halo',
      });

      expect(comment.postId, 1);
      expect(comment.id, 5);
      expect(comment.name, 'Budi');
      expect(comment.email, 'budi@mail.com');
      expect(comment.body, 'Halo');
    });

    // Test bawaan AI: field tidak tersedia.
    test('fromJson mengisi nilai default saat field tidak tersedia', () {
      final comment = Comment.fromJson(const {});

      expect(comment.postId, 0);
      expect(comment.id, 0);
      expect(comment.name, '');
      expect(comment.email, '');
      expect(comment.body, '');
    });

    // Edge case tambahan 1: field ada tetapi bernilai null.
    test('nilai null eksplisit diganti default', () {
      final comment = Comment.fromJson(const {
        'postId': null,
        'id': null,
        'name': null,
        'email': null,
        'body': null,
      });

      expect(comment.id, 0);
      expect(comment.name, '');
      expect(comment.body, '');
    });

    // Edge case tambahan 2: tipe data salah dari server.
    test('tipe salah tidak menyebabkan crash', () {
      final comment = Comment.fromJson(const {
        'postId': '1', // seharusnya angka
        'id': 'abc', // seharusnya angka
        'name': 123, // seharusnya string
        'email': true, // seharusnya string
        'body': ['x'], // seharusnya string
      });

      expect(comment.postId, 0);
      expect(comment.id, 0);
      expect(comment.name, '');
      expect(comment.email, '');
      expect(comment.body, '');
    });

    // Edge case tambahan 3: angka desimal dipotong menjadi int.
    test('angka desimal dikonversi ke int', () {
      final comment = Comment.fromJson(const {'postId': 2.9, 'id': 7.0});

      expect(comment.postId, 2);
      expect(comment.id, 7);
    });
  });

  group('Post.fromJson', () {
    // Gagal sebelum perbaikan B karena cast `as String?` melempar TypeError.
    test('tipe salah tidak menyebabkan crash', () {
      final post = Post.fromJson(const {
        'userId': '1',
        'id': 'x',
        'title': 123,
        'body': false,
      });

      expect(post.userId, 0);
      expect(post.id, 0);
      expect(post.title, '');
      expect(post.body, '');
    });
  });
}