import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routes.dart';
import '../providers/auth_providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Navigasi ke beranda saat sesi login aktif dideteksi
    ref.listen(authStateProvider, (_, next) {
      if (next.hasValue && next.value != null) {
        context.go(AppRoutes.home);
      }
    });

    final auth = ref.watch(authStateProvider);
    final authError = auth.error;

    return Scaffold(
      appBar: AppBar(title: const Text('Masuk')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Kata sandi'),
            ),
            const SizedBox(height: 16),
            if (auth.hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  authError is String
                      ? authError
                      : 'Terjadi kesalahan. Silakan coba lagi.',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            FilledButton(
              onPressed: auth.isLoading
                  ? null
                  : () => ref.read(authStateProvider.notifier).login(
                        email: _email.text.trim(),
                        password: _password.text,
                      ),
              child: auth.isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Masuk'),
            ),
          ],
        ),
      ),
    );
  }
}
