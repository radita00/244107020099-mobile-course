import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../providers/push_provider.dart';
import '../../../../routes.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/announcements_providers.dart';
import '../widgets/announcement_list.dart';
import '../widgets/push_status_panel.dart';
import '../widgets/search_field.dart';

/// Halaman utama: daftar pengumuman + pencarian judul.
///
/// Halaman ini hanya mengurus lifecycle dan navigasi. Render daftar, kotak
/// pencarian, dan panel push dipecah ke widget masing-masing di `widgets/`.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String? _token;
  String _status = 'Menunggu izin notifikasi...';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initPush());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  Future<void> _sendTestNotification() async {
    final pushService = ref.read(pushServiceProvider);
    await pushService.showLocalNotification(
      title: 'Uji Kampus',
      body: 'Notifikasi lokal pengumuman #3 berhasil!',
      payload: AppRoutes.announcement('3'),
    );
    _info('Notifikasi lokal dikirim');
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Daftar Pengumuman',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          SearchField(controller: _searchController),
          const SizedBox(height: 8),
          const AnnouncementList(),
          const Divider(height: 32),
          PushStatusPanel(
            status: _status,
            maskedToken: _token == null ? '(belum ada)' : _mask(_token!),
            onTestNotification: _sendTestNotification,
          ),
        ],
      ),
    );
  }
}
