import 'package:campus_notify/core/failures.dart';
import 'package:campus_notify/features/announcements/domain/entities/announcement.dart';
import 'package:campus_notify/features/announcements/domain/repositories/announcement_repository.dart';
import 'package:campus_notify/features/announcements/domain/usecases/get_announcement_detail.dart';
import 'package:campus_notify/features/announcements/domain/usecases/get_announcements.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAnnouncementRepository implements AnnouncementRepository {
  FakeAnnouncementRepository({this.items = const [], this.fail = false});

  final List<Announcement> items;
  final bool fail;

  @override
  Future<({List<Announcement> items, Failure? failure})> getAnnouncements() async {
    if (fail) {
      return (items: const <Announcement>[], failure: const ServerFailure('Server error'));
    }
    return (items: items, failure: null);
  }

  @override
  Future<({Announcement? item, Failure? failure})> getAnnouncementById(String id) async {
    if (fail) {
      return (item: null, failure: const ServerFailure('Server error'));
    }
    final found = items.where((e) => e.id == id).firstOrNull;
    if (found == null) {
      return (item: null, failure: const LocalFailure('Not found'));
    }
    return (item: found, failure: null);
  }
}

void main() {
  group('Announcements Domain Use Cases', () {
    test('GetAnnouncements mengembalikan daftar pengumuman', () async {
      final repo = FakeAnnouncementRepository(items: [
        const Announcement(id: '1', title: 'Judul 1', body: 'Isi 1'),
        const Announcement(id: '2', title: 'Judul 2', body: 'Isi 2'),
      ]);
      final useCase = GetAnnouncements(repo);

      final result = await useCase();

      expect(result.failure, isNull);
      expect(result.items.length, 2);
      expect(result.items.first.title, 'Judul 1');
    });

    test('GetAnnouncementDetail mengembalikan item spesifik jika ditemukan', () async {
      final repo = FakeAnnouncementRepository(items: [
        const Announcement(id: '3', title: 'Seminar', body: 'Ruang A'),
      ]);
      final useCase = GetAnnouncementDetail(repo);

      final result = await useCase('3');

      expect(result.failure, isNull);
      expect(result.item, isNotNull);
      expect(result.item?.title, 'Seminar');
    });

    test('GetAnnouncementDetail menolak ID kosong dengan ValidationFailure', () async {
      final repo = FakeAnnouncementRepository();
      final useCase = GetAnnouncementDetail(repo);

      final result = await useCase('');

      expect(result.item, isNull);
      expect(result.failure, isA<ValidationFailure>());
    });
  });
}
