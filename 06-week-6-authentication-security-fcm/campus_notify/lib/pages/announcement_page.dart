import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routes.dart';

class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({super.key, required this.id});
  final String id;

  // Data contoh. Di aplikasi nyata, ambil dari API kampus berdasarkan id.
  static const _data = <String, Map<String, String>>{
    '1': {
      'title': 'Pengumuman perkuliahan',
      'body': 'Perkuliahan minggu ini berjalan seperti biasa.',
    },
    '2': {
      'title': 'Pengumuman ujian',
      'body': 'Jadwal ujian akan diumumkan melalui portal akademik.',
    },
    '3': {
      'title': 'Jadwal kuliah berubah',
      'body': 'Kelas Mobile pindah ke Ruang A2 jam 13.00',
    },
  };

  @override
  Widget build(BuildContext context) {
    final item = _data[id];
    final title = item?['title'] ?? 'Pengumuman tidak ditemukan';
    final body = item?['body'] ??
        'Tidak ada data untuk pengumuman dengan id: $id.';

    return Scaffold(
      appBar: AppBar(
        title: Text('Pengumuman #$id'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.campaign),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(body, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  const Divider(),
                  Text(
                    'ID pengumuman: $id\nSumber: topik pengumuman-kampus',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}