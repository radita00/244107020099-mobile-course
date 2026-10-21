import '../../domain/entities/announcement.dart';

/// Model untuk Announcement di Data Layer.
/// Bertanggung jawab atas konversi JSON dan serialisasi data.
class AnnouncementModel extends Announcement {
  const AnnouncementModel({
    required super.id,
    required super.title,
    required super.body,
    super.author,
    super.createdAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      author: json['author'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'author': author,
        'created_at': createdAt?.toIso8601String(),
      };

  Announcement toEntity() => Announcement(
        id: id,
        title: title,
        body: body,
        author: author,
        createdAt: createdAt,
      );
}
