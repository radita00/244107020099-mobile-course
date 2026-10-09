import 'package:dio/dio.dart';

/// Mengubah exception teknis menjadi pesan yang aman ditampilkan ke pengguna.
/// Dipakai bersama oleh halaman biasa, halaman paged, dan halaman detail.
String friendlyErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi lambat atau timeout. Periksa internet Anda lalu coba lagi.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Periksa internet Anda.';
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        if (code == 404) return 'Data tidak ditemukan (404).';
        if (code == 401 || code == 403) {
          return 'Akses ditolak ($code). Periksa kredensial Anda.';
        }
        if (code != null && code >= 500) {
          return 'Server sedang bermasalah ($code). Coba lagi nanti.';
        }
        return 'Permintaan gagal ($code). Coba lagi nanti.';
      case DioExceptionType.cancel:
        return 'Permintaan dibatalkan.';
      case DioExceptionType.badCertificate:
        return 'Sertifikat keamanan server tidak valid.';
      default:
        return 'Terjadi kesalahan jaringan. Coba lagi.';
    }
  }
  return 'Terjadi kesalahan tak terduga. Coba lagi nanti.';
} 