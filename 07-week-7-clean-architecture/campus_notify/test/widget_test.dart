import 'package:campus_notify/features/announcements/presentation/pages/announcement_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('announcement page renders the selected announcement',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AnnouncementPage(id: '3'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Pengumuman #3'), findsOneWidget);
    expect(find.text('Jadwal kuliah berubah'), findsOneWidget);
    expect(
      find.text('Kelas Mobile pindah ke Ruang A2 jam 13.00.'),
      findsOneWidget,
    );
  });
}
