import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/announcement_repository_impl.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../../domain/usecases/get_announcement_detail.dart';
import '../../domain/usecases/get_announcements.dart';
import '../../domain/usecases/search_announcements.dart';

// DI: Data layer
final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepositoryImpl();
});

// DI: Domain layer (use cases)
final getAnnouncementsUseCaseProvider = Provider<GetAnnouncements>((ref) {
  return GetAnnouncements(ref.watch(announcementRepositoryProvider));
});

final getAnnouncementDetailUseCaseProvider = Provider<GetAnnouncementDetail>((
  ref,
) {
  return GetAnnouncementDetail(ref.watch(announcementRepositoryProvider));
});

// Presentation layer: State untuk daftar pengumuman
final announcementsProvider = FutureProvider<List<Announcement>>((ref) async {
  final useCase = ref.watch(getAnnouncementsUseCaseProvider);
  final result = await useCase();
  if (result.failure != null) {
    throw Exception(result.failure!.message);
  }
  return result.items;
});

// Presentation layer: State untuk detail pengumuman spesifik
final announcementDetailProvider = FutureProvider.family<Announcement?, String>(
  (ref, id) async {
    final useCase = ref.watch(getAnnouncementDetailUseCaseProvider);
    final result = await useCase(id);
    if (result.failure != null) {
      throw Exception(result.failure!.message);
    }
    return result.item;
  },
);

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
