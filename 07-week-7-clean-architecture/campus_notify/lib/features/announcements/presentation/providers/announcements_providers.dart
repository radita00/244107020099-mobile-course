import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/announcement_repository_impl.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../../domain/usecases/get_announcement_detail.dart';
import '../../domain/usecases/get_announcements.dart';

// DI: Data layer
final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepositoryImpl();
});

// DI: Domain layer (use cases)
final getAnnouncementsUseCaseProvider = Provider<GetAnnouncements>((ref) {
  return GetAnnouncements(ref.watch(announcementRepositoryProvider));
});

final getAnnouncementDetailUseCaseProvider =
    Provider<GetAnnouncementDetail>((ref) {
  return GetAnnouncementDetail(ref.watch(announcementRepositoryProvider));
});

// Presentation layer: State untuk daftar pengumuman
final announcementsProvider =
    FutureProvider<List<Announcement>>((ref) async {
  final useCase = ref.watch(getAnnouncementsUseCaseProvider);
  final result = await useCase();
  if (result.failure != null) {
    throw Exception(result.failure!.message);
  }
  return result.items;
});

// Presentation layer: State untuk detail pengumuman spesifik
final announcementDetailProvider =
    FutureProvider.family<Announcement?, String>((ref, id) async {
  final useCase = ref.watch(getAnnouncementDetailUseCaseProvider);
  final result = await useCase(id);
  if (result.failure != null) {
    throw Exception(result.failure!.message);
  }
  return result.item;
});
