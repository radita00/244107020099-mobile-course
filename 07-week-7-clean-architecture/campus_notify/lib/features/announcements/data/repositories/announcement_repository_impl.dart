import '../../../../core/failures.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../models/announcement_model.dart';

/// Implementasi konkret dari [AnnouncementRepository].
class AnnouncementRepositoryImpl implements AnnouncementRepository {
  AnnouncementRepositoryImpl({
    Map<String, Map<String, dynamic>>? initialData,
  }) : _data = initialData ?? _defaultData;

  final Map<String, Map<String, dynamic>> _data;

  static final _defaultData = <String, Map<String, dynamic>>{
    '1': {
      'id': '1',
      'title': 'Pengumuman perkuliahan',
      'body': 'Perkuliahan minggu ini berjalan seperti biasa.',
      'author': 'Akademik',
      'created_at': '2026-10-18T08:00:00Z',
    },
    '2': {
      'id': '2',
      'title': 'Pengumuman ujian',
      'body': 'Jadwal ujian akan diumumkan melalui portal akademik.',
      'author': 'Biro Akademik',
      'created_at': '2026-10-19T09:30:00Z',
    },
    '3': {
      'id': '3',
      'title': 'Jadwal kuliah berubah',
      'body': 'Kelas Mobile pindah ke Ruang A2 jam 13.00.',
      'author': 'Dosen Pengampu',
      'created_at': '2026-10-20T10:15:00Z',
    },
    '7': {
      'id': '7',
      'title': 'Pendaftaran seminar dibuka',
      'body': 'Pendaftaran seminar teknologi terbuka untuk seluruh mahasiswa tingkat akhir.',
      'author': 'Himpunan Mahasiswa',
      'created_at': '2026-10-20T11:00:00Z',
    },
  };

  @override
  Future<({List<Announcement> items, Failure? failure})> getAnnouncements() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final items = _data.values
          .map((json) => AnnouncementModel.fromJson(json).toEntity())
          .toList();
      return (items: items, failure: null);
    } catch (e) {
      return (
        items: const <Announcement>[],
        failure: ServerFailure('Gagal memuat pengumuman: $e'),
      );
    }
  }

  @override
  Future<({Announcement? item, Failure? failure})> getAnnouncementById(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      final raw = _data[id];
      if (raw == null) {
        return (
          item: null,
          failure: const LocalFailure('Pengumuman tidak ditemukan.'),
        );
      }
      final model = AnnouncementModel.fromJson(raw);
      return (item: model.toEntity(), failure: null);
    } catch (e) {
      return (
        item: null,
        failure: ServerFailure('Gagal mengambil data pengumuman: $e'),
      );
    }
  }
}
