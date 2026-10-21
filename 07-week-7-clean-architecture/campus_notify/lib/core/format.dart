library;

/// Utilitas murni untuk pemformatan tanggal dan string.
/// Tidak ada dependensi Flutter atau Widget agar mudah diuji secara murni.

/// Memformat objek [DateTime] ke format ringkas yang ramah pengguna.
/// Contoh: "2026-10-20 22:45"
String formatDateTime(DateTime dateTime) {
  final year = dateTime.year.toString().padLeft(4, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final day = dateTime.day.toString().padLeft(2, '0');
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$year-$month-$day $hour:$minute';
}

/// Memformat objek [DateTime] ke format tanggal saja (YYYY-MM-DD).
String formatDateOnly(DateTime dateTime) {
  final year = dateTime.year.toString().padLeft(4, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final day = dateTime.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

/// Membaca ID pengumuman dari parameter rute dengan validasi murni.
int? parseAnnouncementId(String? idStr) {
  if (idStr == null || idStr.trim().isEmpty) return null;
  return int.tryParse(idStr.trim());
}
