import 'package:campus_notify/core/format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Core Formatting and Parsing', () {
    test('formatDateTime memformat tanggal dan waktu dengan tepat', () {
      final dt = DateTime(2026, 10, 20, 14, 5);
      expect(formatDateTime(dt), '2026-10-20 14:05');
    });

    test('formatDateOnly memformat tanggal saja', () {
      final dt = DateTime(2026, 9, 27, 8, 30);
      expect(formatDateOnly(dt), '2026-09-27');
    });

    test('parseAnnouncementId memvalidasi dan mem-parsing ID angka', () {
      expect(parseAnnouncementId('42'), 42);
      expect(parseAnnouncementId('   7   '), 7);
      expect(parseAnnouncementId(null), isNull);
      expect(parseAnnouncementId('abc'), isNull);
      expect(parseAnnouncementId(''), isNull);
    });
  });
}
