import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

// Dibuat sekali di level atas agar tidak dibuat ulang saat MyApp rebuild.
final _router = createRouter();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Week 4 - REST API',
        theme: ThemeData(
            colorSchemeSeed: Colors.indigo, useMaterial3: true),
        routerConfig: _router,
      );
}