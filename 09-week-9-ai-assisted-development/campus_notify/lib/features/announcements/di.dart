import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/repositories/announcement_repository_impl.dart';
import 'domain/repositories/announcement_repository.dart';

/// Composition root fitur announcements.
///
/// Satu-satunya berkas di fitur ini yang boleh mengimpor `data/`. Lapisan
/// presentation cukup bergantung pada `AnnouncementRepository` (domain) lewat
/// provider ini, sehingga tidak ada import lintas layer dari `presentation/`.
final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepositoryImpl();
});
