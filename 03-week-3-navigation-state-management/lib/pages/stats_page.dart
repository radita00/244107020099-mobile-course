import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/stats_provider.dart';

// ConsumerWidget diperlukan agar halaman dapat membaca status dari Riverpod.
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  // Memilih tampilan berdasarkan status asynchronous dari provider.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      body: statsAsync.when(
        // Spinner memberi tanda bahwa data sedang disimulasikan untuk dimuat.
        loading: () => const Center(child: CircularProgressIndicator()),
        // Pesan error dan tombol retry ditampilkan saat pengambilan data gagal.
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Gagal memuat statistik: $error',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  // Invalidate menjalankan kembali build notifier untuk retry.
                  onPressed: () => ref.invalidate(statsProvider),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
        // Data berhasil ditampilkan sebagai daftar tiga item statistik.
        data: (stats) => ListView.builder(
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            return ListTile(
              leading: const Icon(Icons.query_stats),
              title: Text(stat.title),
              trailing: Text(
                stat.value,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          },
        ),
      ),
    );
  }
}
