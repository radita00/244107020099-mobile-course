import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/prefs.dart';
import '../providers.dart';

final prefsRepositoryProvider = Provider((ref) => PrefsRepository());
final darkModeProvider =
    AsyncNotifierProvider<DarkModeNotifier, bool>(DarkModeNotifier.new);

/// Waktu aplikasi dibuka SEBELUM sesi ini (diisi lewat override di main.dart).
final previousOpenedProvider = Provider<String?>((ref) => null);

class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() =>
      ref.watch(prefsRepositoryProvider).getDarkMode();

  Future<void> toggle() async {
    final next = !(state.value ?? false);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(prefsRepositoryProvider).setDarkMode(next);
      return next;
    });
  }
}

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = ref.watch(darkModeProvider);
    final forceOffline = ref.watch(forceOfflineProvider);
    final lastOpened = ref.watch(previousOpenedProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Mode gelap'),
            subtitle: const Text('Tersimpan di SharedPreferences'),
            value: dark.value ?? false,
            onChanged: dark.isLoading
                ? null
                : (_) => ref.read(darkModeProvider.notifier).toggle(),
          ),
          SwitchListTile(
            title: const Text('Force offline'),
            subtitle: const Text('Simulasi offline untuk demo & testing'),
            value: forceOffline,
            onChanged: (v) =>
                ref.read(forceOfflineProvider.notifier).set(v),
          ),
          ListTile(
            title: const Text('Terakhir dibuka'),
            subtitle: Text(lastOpened ?? 'Pertama kali dibuka'),
          ),
        ],
      ),
    );
  }
}