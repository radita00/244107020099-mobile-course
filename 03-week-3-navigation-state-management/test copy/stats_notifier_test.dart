import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_todo/providers/stats_provider.dart';

void main() {
  // Verifikasi bahwa pengambilan data berhasil menghasilkan tiga statistik.
  test('mengembalikan tiga item statistik saat berhasil', () async {
    final container = ProviderContainer.test(
      retry: (retryCount, error) => null,
      overrides: [
        statsProvider.overrideWith(
          () => StatsNotifier(nextRandom: () => 0.5, delay: Duration.zero),
        ),
      ],
    );

    final stats = await container.read(statsProvider.future);

    expect(stats, hasLength(3));
    expect(stats.first.title, 'Total Pengguna');
  });

  // Nilai acak di bawah 0,3 harus menghasilkan error dari notifier.
  test('menghasilkan error saat peluang gagal tercapai', () async {
    final container = ProviderContainer.test(
      retry: (retryCount, error) => null,
      overrides: [
        statsProvider.overrideWith(
          () => StatsNotifier(nextRandom: () => 0.2, delay: Duration.zero),
        ),
      ],
    );
    final errorState = Completer<AsyncValue<List<StatItem>>>();
    final subscription = container.listen(statsProvider, (previous, next) {
      if (next.hasError && !errorState.isCompleted) {
        errorState.complete(next);
      }
    }, fireImmediately: true);

    final result = await errorState.future;

    expect(result.error, isA<Exception>());
    subscription.close();
  });
}
