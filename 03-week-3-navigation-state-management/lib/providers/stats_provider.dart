import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Satu item statistik yang ditampilkan sebagai satu baris pada halaman.
class StatItem {
  const StatItem({required this.title, required this.value});

  final String title;
  final String value;
}

// Mengambil data statistik secara asinkron dan sesekali mensimulasikan kegagalan.
class StatsNotifier extends AsyncNotifier<List<StatItem>> {
  StatsNotifier({
    double Function()? nextRandom,
    this._delay = const Duration(seconds: 2),
  }) : _nextRandom = nextRandom ?? Random().nextDouble;

  final double Function() _nextRandom;
  final Duration _delay;

  // Riverpod menjalankan build saat provider pertama kali dibaca atau di-invalidate.
  @override
  Future<List<StatItem>> build() async {
    await Future<void>.delayed(_delay);

    // Peluang gagal 30% membuat alur error dan retry dapat dicoba di aplikasi.
    if (_nextRandom() < 0.3) {
      throw Exception('Data statistik gagal dimuat.');
    }

    // Data contoh dikembalikan setelah simulasi pengambilan data berhasil.
    return const [
      StatItem(title: 'Total Pengguna', value: '1.248'),
      StatItem(title: 'Pesanan Hari Ini', value: '86'),
      StatItem(title: 'Pendapatan Bulan Ini', value: 'Rp 24.500.000'),
    ];
  }
}

// Mengembalikan null = jangan coba ulang. Error langsung tampil di UI.
Duration? noRetry(int retryCount, Object error) => null;

final statsProvider = AsyncNotifierProvider<StatsNotifier, List<StatItem>>(
  StatsNotifier.new,
  retry: noRetry,
);
