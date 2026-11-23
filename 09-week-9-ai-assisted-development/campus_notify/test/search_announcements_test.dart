import 'package:campus_notify/features/announcements/domain/entities/announcement.dart';
import 'package:campus_notify/features/announcements/domain/usecases/search_announcements.dart';
import 'package:flutter_test/flutter_test.dart';

Announcement _item({required String id, required String title}) {
  return Announcement(id: id, title: title, body: 'Isi pengumuman $id');
}

void main() {
  const search = SearchAnnouncements();
  final items = <Announcement>[
    _item(id: '1', title: 'Libur Semester Ganjil'),
    _item(id: '2', title: 'Beasiswa Unggulan 2026'),
    _item(id: '3', title: 'Jadwal UTS'),
  ];

  group('SearchAnnouncements', () {
    test('query kosong mengembalikan seluruh pengumuman', () {
      expect(search(items, ''), hasLength(3));
      expect(search(items, '   '), hasLength(3));
    });

    test('query yang cocok mengembalikan pengumuman yang sesuai', () {
      final result = search(items, 'beasiswa');

      expect(result, hasLength(1));
      expect(result.single.id, '2');
    });

    test('pencarian tidak membedakan huruf besar dan kecil', () {
      expect(search(items, 'LIBUR'), hasLength(1));
      expect(search(items, 'libur').single.id, '1');
      expect(search(items, 'LiBuR').single.id, '1');
    });

    test('query tanpa hasil mengembalikan daftar kosong', () {
      expect(search(items, 'konser'), isEmpty);
    });
  });
}
