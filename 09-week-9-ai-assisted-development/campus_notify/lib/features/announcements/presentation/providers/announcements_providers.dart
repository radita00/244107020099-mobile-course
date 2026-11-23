import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/usecases/get_announcement_detail.dart';
import '../../domain/usecases/get_announcements.dart';

// DI: Domain layer (use cases). Implementasi data layer ada di `di.dart`.
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
