import 'package:flutter/material.dart';

/// Empty state daftar pengumuman.
///
/// Dua kondisi dibedakan supaya pengguna tahu penyebabnya:
/// - data memang belum ada  -> "Belum ada pengumuman."
/// - filter tidak menemukan -> "Tidak ada pengumuman yang cocok dengan ..."
class EmptyAnnouncementState extends StatelessWidget {
  const EmptyAnnouncementState({super.key, required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final trimmed = query.trim();
    final isSearching = trimmed.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            Icon(
              isSearching ? Icons.search_off : Icons.inbox,
              size: 40,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Tidak ada pengumuman yang cocok dengan "$trimmed"'
                  : 'Belum ada pengumuman.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
