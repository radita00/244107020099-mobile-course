import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'messaging/push_service.dart';
import 'pages/announcement_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'providers/auth_provider.dart';
import 'routes.dart';

final container = ProviderContainer();

final router = GoRouter(
  redirect: (context, state) {
    final loggedIn =
        container.read(authStateProvider).value ?? false;
    final goingLogin = state.matchedLocation == AppRoutes.login;
    if (!loggedIn && !goingLogin) return AppRoutes.login;
    if (loggedIn && goingLogin) return AppRoutes.home;
    return null;
  },
  routes: [
    GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginPage()),
    GoRoute(path: AppRoutes.home, builder: (_, _) => const HomePage()),
    GoRoute(
      path: AppRoutes.announcementPattern,
      builder: (_, s) =>
          AnnouncementPage(id: s.pathParameters['id'] ?? ''),
    ),
  ],
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // wajib sebelum runApp
  registerBackgroundHandler();    // Praktikum 3
  await initLocalNotifications();
  runApp(UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(
      title: 'Campus Notify',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      routerConfig: router,
    ),
  ));
}