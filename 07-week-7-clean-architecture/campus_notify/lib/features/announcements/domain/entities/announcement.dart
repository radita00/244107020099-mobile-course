/// Entity murni untuk pengumuman kampus.
/// Bebas dari ketergantungan Flutter, JSON, atau Dio.
class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    this.author,
    this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final String? author;
  final DateTime? createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Announcement &&
          other.id == id &&
          other.title == title &&
          other.body == body;

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ body.hashCode;
}
