import '../../../../core/failures.dart';
import '../entities/announcement.dart';
import '../repositories/announcement_repository.dart';

/// Use case: Mengambil detail pengumuman spesifik berdasarkan ID.
class GetAnnouncementDetail {
  const GetAnnouncementDetail(this._repository);
  final AnnouncementRepository _repository;

  Future<({Announcement? item, Failure? failure})> call(String id) {
    final cleanId = id.trim();
    if (cleanId.isEmpty) {
      return Future.value((
        item: null,
        failure: const ValidationFailure('ID pengumuman tidak boleh kosong.'),
      ));
    }
    return _repository.getAnnouncementById(cleanId);
  }
}
