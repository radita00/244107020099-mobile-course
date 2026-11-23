import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../providers/push_provider.dart';
import '../../../../routes.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/announcements_providers.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String? _token;
  String _status = 'Menunggu izin notifikasi...';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initPush());
  }

  Future<void> _initPush() async {
    final router = GoRouter.of(context);
    final pushService = ref.read(pushServiceProvider);

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

      await pushService.registerToken(
        onToken: (token) {
          if (mounted) setState(() => _token = token);
        },
      );
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

  void _info(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _logout() async {
    await ref.read(authStateProvider.notifier).logout();
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final pushService = ref.read(pushServiceProvider);
    final announcementsState = ref.watch(announcementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Notify'),
        actions: [
          IconButton(
            tooltip: 'Segarkan',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(announcementsProvider),
          ),
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Daftar Pengumuman',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          announcementsState.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Gagal memuat pengumuman: $err',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
            data: (items) {
              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text('Belum ada pengumuman.')),
                );
              }
              return Column(
                children: items.map((announcement) {
                  return ListTile(
                    leading: const Icon(Icons.campaign),
                    title: Text(announcement.title),
                    subtitle: Text(announcement.body),
                    onTap: () =>
                        context.go(AppRoutes.announcement(announcement.id)),
                  );
                }).toList(),
              );
            },
          ),
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status FCM: $_status'),
                const SizedBox(height: 4),
                Text(
                  'Token: ${_token == null ? "(belum ada)" : _mask(_token!)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.notifications_active),
                  label: const Text('Uji Notifikasi Lokal'),
                  onPressed: () async {
                    await pushService.showLocalNotification(
                      title: 'Uji Kampus',
                      body: 'Notifikasi lokal pengumuman #3 berhasil!',
                      payload: AppRoutes.announcement('3'),
                    );
                    _info('Notifikasi lokal dikirim');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
