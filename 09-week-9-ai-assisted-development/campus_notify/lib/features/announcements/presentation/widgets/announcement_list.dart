import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routes.dart';
import '../providers/search_providers.dart';
import 'empty_announcement_state.dart';

/// Daftar pengumuman beserta status loading, error, dan empty.
///
/// Widget ini hanya membaca provider hasil filter ([filteredAnnouncementsProvider]).
/// Aturan pencarian ada di domain (`SearchAnnouncements`), bukan di sini.
class AnnouncementList extends ConsumerWidget {
  const AnnouncementList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(filteredAnnouncementsProvider);
    final query = ref.watch(searchQueryProvider);

    return state.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, _) => _ErrorView(message: '$err'),
      data: (items) {
        if (items.isEmpty) return EmptyAnnouncementState(query: query);
        return Column(
          children: [
            for (final announcement in items)
              ListTile(
                leading: const Icon(Icons.campaign),
                title: Text(announcement.title),
                subtitle: Text(announcement.body),
                onTap: () =>
                    context.go(AppRoutes.announcement(announcement.id)),
              ),
          ],
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          'Gagal memuat pengumuman: $message',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
  }
}
