import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../messaging/push_service.dart';
export '../messaging/push_service.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(baseUrl: 'https://example-campus-api.test'));
});

final pushServiceProvider = Provider<PushService>((ref) {
  final service = PushService(dio: ref.watch(dioProvider));
  ref.onDispose(() => unawaited(service.dispose()));
  return service;
});