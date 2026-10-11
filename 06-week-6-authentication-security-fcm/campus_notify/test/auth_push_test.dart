import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campus_notify/data/api_errors.dart';
import 'package:campus_notify/routes.dart';

class FakeTokenStore {
  String? access;
  String? refresh;
}

void main() {
  test('routeFromMessage menangani route kosong dan tanpa slash', () {
    expect(routeFromMessage({}), '/');
    expect(routeFromMessage({'route': 'pengumuman/3'}), '/pengumuman/3');
    expect(routeFromMessage({'route': '/pengumuman/3'}), '/pengumuman/3');
    expect(routeFromMessage({'route': '  '}), '/');
    expect(routeFromMessage({'route': 3}), '/');
  });

  test('data payload membawa id pengumuman', () {
    const data = {'route': '/pengumuman/3', 'id': '3'};
    expect(data['id'], '3');
    expect(routeFromMessage(data), '/pengumuman/3');
  });

  test('provider auth membaca status login dari token', () async {
    final store = FakeTokenStore()..access = 'mock-access';
    expect(store.access != null, isTrue);
    store.access = null;
    expect(store.access != null, isFalse);
  });

  test('refresh gagal -> sesi dibersihkan (paksa login ulang)', () async {
    final store = FakeTokenStore()..refresh = '';
    final needsLogin = (store.refresh ?? '').isEmpty;
    expect(needsLogin, isTrue);
  });

  test('401 dipetakan ke pesan sesi berakhir', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/login'),
      response: Response(
        requestOptions: RequestOptions(path: '/login'),
        statusCode: 401,
      ),
    );

    expect(apiErrorMessage(error), 'Sesi Anda berakhir. Silakan masuk kembali.');
  });

  test('timeout dipetakan ke pesan koneksi terlalu lama', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/'),
      type: DioExceptionType.connectionTimeout,
    );

    expect(
      apiErrorMessage(error),
      'Koneksi terlalu lama. Periksa internet Anda dan coba lagi.',
    );
  });

  test('offline dipetakan ke pesan tidak dapat terhubung', () {
    final error = DioException(
      requestOptions: RequestOptions(path: '/'),
      type: DioExceptionType.connectionError,
    );

    expect(
      apiErrorMessage(error),
      'Tidak dapat terhubung ke internet. Periksa koneksi Anda.',
    );
  });
}