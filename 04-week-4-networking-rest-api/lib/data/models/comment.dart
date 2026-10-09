/// Model komentar JSONPlaceholder dengan nilai default untuk field yang hilang.
class Comment {
  /// Membuat komentar dari nilai yang sudah dinormalisasi.
  const Comment({
    required this.postId,
    required this.id,
    required this.name,
    required this.email,
    required this.body,
  });

  /// ID post yang memiliki komentar.
  final int postId;

  /// ID unik komentar.
  final int id;

  /// Nama penulis komentar.
  final String name;

  /// Email penulis komentar.
  final String email;

  /// Isi komentar.
  final String body;

  /// Membaca JSON dengan guard tipe dan default agar field null/hilang aman.
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      postId: json['postId'] is num ? (json['postId'] as num).toInt() : 0,
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      name: json['name'] is String ? json['name'] as String : '',
      email: json['email'] is String ? json['email'] as String : '',
      body: json['body'] is String ? json['body'] as String : '',
    );
  }
}
