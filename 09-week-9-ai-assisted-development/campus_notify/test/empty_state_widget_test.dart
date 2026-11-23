import 'package:campus_notify/features/announcements/presentation/widgets/empty_announcement_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpEmptyState(WidgetTester tester, String query) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: EmptyAnnouncementState(query: query)),
      ),
    );
  }

  group('EmptyAnnouncementState', () {
    testWidgets('query kosong menampilkan pesan data belum ada', (
      tester,
    ) async {
      await pumpEmptyState(tester, '');

      expect(find.text('Belum ada pengumuman.'), findsOneWidget);
      expect(find.byIcon(Icons.inbox), findsOneWidget);
      expect(find.byIcon(Icons.search_off), findsNothing);
    });

    testWidgets('query terisi menampilkan pesan tidak cocok', (tester) async {
      await pumpEmptyState(tester, 'zzz');

      expect(
        find.text('Tidak ada pengumuman yang cocok dengan "zzz"'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.search_off), findsOneWidget);
      expect(find.byIcon(Icons.inbox), findsNothing);
    });

    testWidgets('query berisi spasi saja diperlakukan seperti kosong', (
      tester,
    ) async {
      await pumpEmptyState(tester, '   ');

      expect(find.text('Belum ada pengumuman.'), findsOneWidget);
      expect(find.byIcon(Icons.search_off), findsNothing);
    });
  });
}
