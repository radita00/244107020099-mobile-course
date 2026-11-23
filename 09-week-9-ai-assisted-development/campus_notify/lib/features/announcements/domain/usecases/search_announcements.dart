import '../entities/announcement.dart';

/// Use case: mencari pengumuman berdasarkan judul.
///
/// Murni Dart — tidak bergantung pada Flutter, Dio, atau sumber data apa pun,
/// sehingga bisa diuji tanpa emulator maupun jaringan.
class SearchAnnouncements {
  const SearchAnnouncements();

  /// Mengembalikan pengumuman yang judulnya mengandung [query].
  ///
  /// - Pencarian tidak membedakan huruf besar/kecil.
  /// - Spasi di awal/akhir [query] diabaikan.
  /// - [query] kosong mengembalikan seluruh daftar.
  List<Announcement> call(List<Announcement> items, String query) {
    final keyword = query.trim().toLowerCase();
    if (keyword.isEmpty) return List<Announcement>.unmodifiable(items);

    return items
        .where((item) => item.title.toLowerCase().contains(keyword))
        .toList(growable: false);
  }
}
