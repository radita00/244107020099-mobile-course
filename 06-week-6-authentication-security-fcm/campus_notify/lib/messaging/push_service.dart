import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../routes.dart';

const _announcementTopic = 'pengumuman-kampus';
const _notificationChannelId = 'pengumuman';
const _notificationChannelName = 'Pengumuman Kampus';
const _notificationChannelDescription = 'Notifikasi pengumuman kampus';
const _notificationChannel = AndroidNotificationChannel(
  _notificationChannelId,
  _notificationChannelName,
  description: _notificationChannelDescription,
  importance: Importance.high,
);

final _defaultLocalNotifications = FlutterLocalNotificationsPlugin();
String? pendingDeepLink;
void Function(String route)? _notificationNavigationHandler;

class PushService {
  PushService({
    required this.dio,
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _localNotifications = localNotifications ?? _defaultLocalNotifications;

  final Dio dio;
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;

  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;

  Future<bool> requestPermission() async {
    // Android 13+: requests the runtime POST_NOTIFICATIONS permission.
    // iOS: requests the APNs alert, badge, and sound authorization.
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<String?> registerToken() async {
    await _tokenSubscription?.cancel();
    _tokenSubscription = _messaging.onTokenRefresh.listen(
      (token) {
        unawaited(_sendRefreshedToken(token));
      },
      onError: (Object error, StackTrace _) {
        debugPrint(
          'FCM token refresh listener failed (${error.runtimeType})',
        );
      },
    );

    final token = await _messaging.getToken();
    if (token != null) await _sendToken(token);
    return token;
  }

  Future<void> _sendToken(String token) async {
    await dio.post(
      '/devices',
      data: {
        'fcm_token': token,
        'platform': Platform.isIOS ? 'ios' : 'android',
      },
    );
  }

  Future<void> _sendRefreshedToken(String token) async {
    try {
      await _sendToken(token);
    } catch (error) {
      debugPrint(
        'Failed to update FCM token at POST /devices '
        '(${error.runtimeType})',
      );
    }
  }

  Future<void> listenForMessages({
    required void Function(String route) onNavigate,
  }) async {
    _notificationNavigationHandler = onNavigate;

    await _foregroundSubscription?.cancel();
    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      _showForegroundNotification,
      onError: (Object error, StackTrace _) {
        debugPrint('Foreground FCM listener failed (${error.runtimeType})');
      },
    );

    await _openedSubscription?.cancel();
    _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => _navigateToMessage(message, onNavigate),
      onError: (Object error, StackTrace _) {
        debugPrint(
          'FCM notification-open listener failed (${error.runtimeType})',
        );
      },
    );
  }

  Future<void> handleInitialMessage({
    required void Function(String route) onNavigate,
  }) async {
    final message = await _messaging.getInitialMessage();
    if (message != null) {
      pendingDeepLink = null;
      _navigateToMessage(message, onNavigate);
      return;
    }

    final localRoute = pendingDeepLink;
    pendingDeepLink = null;
    if (localRoute != null && localRoute.isNotEmpty) {
      onNavigate(localRoute);
    }
  }

  void _navigateToMessage(
    RemoteMessage message,
    void Function(String route) onNavigate,
  ) {
    onNavigate(routeFromMessage(message.data));
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      _notificationChannelId,
      _notificationChannelName,
      channelDescription: _notificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    final route = routeFromMessage(message.data);

    await _localNotifications.show(
      id: message.messageId?.hashCode ?? message.hashCode,
      title: message.notification?.title ?? 'Pengumuman',
      body: message.notification?.body ?? '',
      notificationDetails: details,
      payload: route,
    );
  }

  Future<void> subscribeToAnnouncements() =>
      _messaging.subscribeToTopic(_announcementTopic);

  Future<void> unsubscribeFromAnnouncements() =>
      _messaging.unsubscribeFromTopic(_announcementTopic);

  Future<void> dispose() async {
    await _tokenSubscription?.cancel();
    await _foregroundSubscription?.cancel();
    await _openedSubscription?.cancel();
    _notificationNavigationHandler = null;
  }
}

Future<void> initLocalNotifications() async {
  const initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    // iOS permission is requested through FirebaseMessaging.requestPermission.
    iOS: DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    ),
  );

  await _defaultLocalNotifications.initialize(
    settings: initializationSettings,
    onDidReceiveNotificationResponse: (response) {
      final route = response.payload;
      if (route == null || route.isEmpty) return;

      final navigate = _notificationNavigationHandler;
      if (navigate == null) {
        pendingDeepLink = route;
      } else {
        navigate(route);
      }
    },
  );

  // Android 8+: notifications must use a channel.
  await _defaultLocalNotifications
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(_notificationChannel);

  final launchDetails = await _defaultLocalNotifications
      .getNotificationAppLaunchDetails();
  final launchRoute = launchDetails?.notificationResponse?.payload;
  if (launchDetails?.didNotificationLaunchApp == true &&
      launchRoute != null &&
      launchRoute.isNotEmpty) {
    pendingDeepLink = launchRoute;
  }
}

// Must be top-level and must not access BuildContext or UI/Riverpod state:
// Firebase runs this callback in a separate background isolate.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Received background FCM message: ${message.messageId}');
}

void registerBackgroundHandler() {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}
