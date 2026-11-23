import 'package:campus_notify/core/failures.dart';
import 'package:campus_notify/features/announcements/domain/entities/announcement.dart';
import 'package:campus_notify/features/announcements/domain/repositories/announcement_repository.dart';
import 'package:campus_notify/features/announcements/presentation/providers/announcements_providers.dart';
import 'package:campus_notify/features/announcements/presentation/providers/search_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _items = <Announcement>[
  Announcement(id: '1', title: 'Libur Semester Ganjil', body: 'Isi 1'),
  Announcement(id: '2', title: 'Beasiswa Unggulan 2026', body: 'Isi 2'),
  Announcement(id: '3', title: 'Jadwal UTS', body: 'Isi 3'),
];

/// Repository palsu: tidak menyentuh jaringan maupun database.
class _FakeAnnouncementRepository implements AnnouncementRepository {
  @override
  Future<({List<Announcement> items, Failure? failure})>
  getAnnouncements() async {
    return (items: _items, failure: null);
  }

  @override
  Future<({Announcement? item, Failure? failure})> getAnnouncementById(
    String id,
  ) async {
    for (final item in _items) {
      if (item.id == id) return (item: item, failure: null);
    }
    return (item: null, failure: null);
  }
}

ProviderContainer _createContainer() {
  return ProviderContainer.test(
    overrides: [
      announcementRepositoryProvider.overrideWithValue(
        _FakeAnnouncementRepository(),
      ),
    ],
  );
}

void main() {
  group('filteredAnnouncementsProvider (wiring notifier -> use case)', () {
    test('query kosong mengembalikan seluruh pengumuman', () async {
      final container = _createContainer();
      await container.read(announcementsProvider.future);

      final result = container.read(filteredAnnouncementsProvider);

      expect(result.value, hasLength(3));
    });

    test('query tidak membedakan huruf besar dan kecil', () async {
      final container = _createContainer();
      await container.read(announcementsProvider.future);

      container.read(searchQueryProvider.notifier).setQuery('BEASISWA');

      final result = container.read(filteredAnnouncementsProvider);
      expect(result.value, hasLength(1));
      expect(result.value!.single.title, 'Beasiswa Unggulan 2026');
    });

    test('query tanpa hasil mengembalikan daftar kosong', () async {
      final container = _createContainer();
      await container.read(announcementsProvider.future);

      container.read(searchQueryProvider.notifier).setQuery('zzz');

      expect(container.read(filteredAnnouncementsProvider).value, isEmpty);
    });

    test('clear() mengembalikan seluruh daftar', () async {
      final container = _createContainer();
      await container.read(announcementsProvider.future);

      final notifier = container.read(searchQueryProvider.notifier);
      notifier.setQuery('uts');
      expect(container.read(filteredAnnouncementsProvider).value, hasLength(1));

      notifier.clear();
      expect(container.read(filteredAnnouncementsProvider).value, hasLength(3));
    });
  });
}
