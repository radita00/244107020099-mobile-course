import '../../../../core/failures.dart';
import '../entities/announcement.dart';

/// Kontrak repository pengumuman di Domain Layer.
abstract interface class AnnouncementRepository {
  /// Mengambil seluruh daftar pengumuman kampus.
  Future<({List<Announcement> items, Failure? failure})> getAnnouncements();

  /// Mengambil detail pengumuman berdasarkan ID.
  Future<({Announcement? item, Failure? failure})> getAnnouncementById(String id);
}
