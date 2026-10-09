import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_todo/main.dart';
import 'package:week3_todo/providers/stats_provider.dart';

void main() {
  // Verifikasi halaman Statistik dapat dibuka dan menampilkan data berhasil.
  testWidgets('menampilkan statistik dari navigasi utama', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Data deterministik menghindari delay dan kegagalan acak dalam test.
          statsProvider.overrideWith(
            () => StatsNotifier(nextRandom: () => 0.5, delay: Duration.zero),
          ),
        ],
        child: const MyApp(),
      ),
    );

    // Buka tab Statistik dari navigasi bawah.
    await tester.tap(find.text('Statistik'));
    await tester.pumpAndSettle();

    // Pastikan daftar statistik berhasil dirender.
    expect(find.text('Total Pengguna'), findsOneWidget);
    expect(find.text('Pesanan Hari Ini'), findsOneWidget);
    expect(find.text('Pendapatan Bulan Ini'), findsOneWidget);
  });
}
