import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../messaging/push_service.dart';
import '../providers/auth_provider.dart';
import '../routes.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String? _token;
  String _status = 'Menunggu izin notifikasi...';
  PushService? _pushService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initPush());
  }

  Future<void> _initPush() async {
    final dio = ref.read(dioProvider);
    // Keep a router reference, not BuildContext, for asynchronous push callbacks.
    final router = GoRouter.of(context);
    final pushService = PushService(dio: dio);
    _pushService = pushService;

    try {
      await pushService.listenForMessages(
        onNavigate: (route) => router.go(route),
      );
      await pushService.handleInitialMessage(
        onNavigate: (route) => router.go(route),
      );

      final granted = await pushService.requestPermission();
      if (!mounted) return;
      if (!granted) {
        setState(() => _status = 'Izin notifikasi ditolak');
        return;
      }
      setState(() => _status = 'Izin notifikasi diberikan');

      final token = await pushService.registerToken();
      if (mounted && token != null) setState(() => _token = token);
      await pushService.subscribeToAnnouncements();
      if (mounted) {
        setState(() => _status = 'Notifikasi aktif; terhubung ke pengumuman');
      }
    } catch (error) {
      debugPrint('Push setup failed (${error.runtimeType})');
      if (mounted) {
        setState(() => _status = 'Gagal menyiapkan push notification');
      }
    }
  }

  String _mask(String t) =>
      '${t.substring(0, t.length < 12 ? t.length : 12)}...';

  @override
  void dispose() {
    final pushService = _pushService;
    if (pushService != null) unawaited(pushService.dispose());
    super.dispose();
  }

  void _info(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _logout() async {
    await ref.read(authStateProvider.notifier).logout();
    await ref.read(authStateProvider.future);
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Notify'),
        actions: [
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.campaign),
            title: const Text('Pengumuman #3'),
            subtitle: const Text('Jadwal kuliah berubah'),
            onTap: () => context.go(AppRoutes.announcement('3')),
          ),
          const Divider(),
          const ListTile(
            title: Text('Debug', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_active),
            title: const Text('Status izin'),
            subtitle: Text(_status),
          ),
          ListTile(
            leading: const Icon(Icons.vpn_key),
            title: const Text('FCM token (terpotong)'),
            subtitle: Text(_token == null ? '(belum ada)' : _mask(_token!)),
          ),
          ListTile(
            leading: const Icon(Icons.topic),
            title: const Text('Topik: pengumuman-kampus'),
            subtitle: Wrap(
              spacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () async {
                    try {
                      await _pushService?.subscribeToAnnouncements();
                      _info('Berlangganan topik pengumuman-kampus');
                    } catch (error) {
                      _info('Gagal subscribe: $error');
                    }
                  },
                  child: const Text('Subscribe'),
                ),
                OutlinedButton(
                  onPressed: () async {
                    try {
                      await _pushService?.unsubscribeFromAnnouncements();
                      _info('Berhenti dari topik pengumuman-kampus');
                    } catch (error) {
                      _info('Gagal unsubscribe: $error');
                    }
                  },
                  child: const Text('Unsubscribe'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
