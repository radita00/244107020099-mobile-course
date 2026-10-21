import '../../../../core/failures.dart';
import '../entities/announcement.dart';
import '../repositories/announcement_repository.dart';

/// Use case: Mengambil daftar pengumuman kampus.
class GetAnnouncements {
  const GetAnnouncements(this._repository);
  final AnnouncementRepository _repository;

  Future<({List<Announcement> items, Failure? failure})> call() {
    return _repository.getAnnouncements();
  }
}
