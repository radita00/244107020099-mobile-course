import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/announcement.dart';
import '../../domain/usecases/search_announcements.dart';
import 'announcements_providers.dart';

// DI: Domain layer (use case pencarian)
final searchAnnouncementsProvider = Provider<SearchAnnouncements>((ref) {
  return const SearchAnnouncements();
});

// Presentation layer: state query pencarian.
// Riverpod 3 memakai Notifier; StateProvider sudah dipindah ke legacy.dart
// sehingga tidak tersedia dari import utama flutter_riverpod.
class SearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) => state = value;

  void clear() => state = '';
}

final searchQueryProvider = NotifierProvider<SearchQuery, String>(
  SearchQuery.new,
);

// Presentation layer: daftar pengumuman yang sudah difilter.
// whenData dipakai supaya status loading/error dari announcementsProvider
// tetap terbawa ke widget.
final filteredAnnouncementsProvider = Provider<AsyncValue<List<Announcement>>>((
  ref,
) {
  final asyncItems = ref.watch(announcementsProvider);
  final query = ref.watch(searchQueryProvider);
  final search = ref.watch(searchAnnouncementsProvider);

  return asyncItems.whenData((items) => search(items, query));
});
