import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/announcements_providers.dart';

/// Kotak pencarian judul pengumuman.
///
/// UI saja: tidak tahu repository, use case, maupun sumber data.
/// State query disimpan di [searchQueryProvider] (notifier), bukan di widget.
class SearchField extends ConsumerWidget {
  const SearchField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        onChanged: (value) =>
            ref.read(searchQueryProvider.notifier).setQuery(value),
        decoration: InputDecoration(
          hintText: 'Cari judul pengumuman...',
          prefixIcon: const Icon(Icons.search),
          border: const OutlineInputBorder(),
          isDense: true,
          suffixIcon: query.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Hapus pencarian',
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    controller.clear();
                    ref.read(searchQueryProvider.notifier).clear();
                  },
                ),
        ),
      ),
    );
  }
}
