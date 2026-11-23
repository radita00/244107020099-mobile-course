import 'package:flutter/material.dart';

/// Panel status push notification (FCM) + tombol uji notifikasi lokal.
///
/// UI saja: seluruh aksi dikirim lewat [onTestNotification] supaya widget ini
/// tidak bergantung pada service FCM maupun provider.
class PushStatusPanel extends StatelessWidget {
  const PushStatusPanel({
    super.key,
    required this.status,
    required this.maskedToken,
    required this.onTestNotification,
  });

  final String status;
  final String maskedToken;
  final VoidCallback onTestNotification;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Status FCM: $status'),
          const SizedBox(height: 4),
          Text(
            'Token: $maskedToken',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.notifications_active),
            label: const Text('Uji Notifikasi Lokal'),
            onPressed: onTestNotification,
          ),
        ],
      ),
    );
  }
}
