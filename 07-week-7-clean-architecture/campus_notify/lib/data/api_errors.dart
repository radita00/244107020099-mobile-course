import 'dart:io';

import 'package:dio/dio.dart';

String apiErrorMessage(Object error) {
  if (error is! DioException) {
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }

  if (error.response?.statusCode == 401) {
    return 'Sesi Anda berakhir. Silakan masuk kembali.';
  }

  if (error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.sendTimeout ||
      error.type == DioExceptionType.receiveTimeout) {
    return 'Koneksi terlalu lama. Periksa internet Anda dan coba lagi.';
  }

  if (error.type == DioExceptionType.connectionError ||
      error.error is SocketException) {
    return 'Tidak dapat terhubung ke internet. Periksa koneksi Anda.';
  }

  return 'Terjadi kesalahan saat menghubungi server. Silakan coba lagi.';
}
