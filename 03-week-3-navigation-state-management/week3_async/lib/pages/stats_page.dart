import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stats_provider.dart';

// ConsumerWidget untuk mengonsumsi Riverpod provider
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch dipanggil HANYA di dalam method build untuk memantau state
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik Aplikasi'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      // Penanganan 3 state AsyncValue: loading, error, dan data (success)
      body: statsAsync.when(
        // 1. Loading state (spinner)
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        // 2. Error state (pesan + tombol retry)
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text(
                  err.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  // Menggunakan ref.invalidate untuk memicu refetch data
                  onPressed: () => ref.invalidate(statsProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        // 3. Success state (ListView 3 item)
        data: (stats) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: stats.length,
          itemBuilder: (context, index) => Card(
            child: ListTile(
              leading: const Icon(Icons.analytics_outlined),
              title: Text(stats[index]),
            ),
          ),
        ),
      ),
    );
  }
}