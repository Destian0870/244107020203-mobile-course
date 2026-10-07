import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart';

final statsAsyncProvider = FutureProvider<Map<String, int>>((ref) async {
  final todos = ref.watch(todoListProvider);
  await Future.delayed(const Duration(seconds: 1));
  final total = todos.length;
  final completed = todos.where((t) => t.done).length;
  return {
    'total': total,
    'completed': completed,
    'pending': total - completed,
  };
});

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsAsyncProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik Tugas')),
      body: Center(
        child: statsAsync.when(
          data: (stats) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text('Total Tugas: ${stats['total']}', style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      Text('Selesai: ${stats['completed']}', style: const TextStyle(fontSize: 18, color: Colors.green)),
                      const SizedBox(height: 8),
                      Text('Belum Selesai: ${stats['pending']}', style: const TextStyle(fontSize: 18, color: Colors.orange)),
                    ],
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(statsAsyncProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Data'),
              ),
            ],
          ),
          loading: () => const CircularProgressIndicator(),
          error: (err, stack) => Text('Error: $err'),
        ),
      ),
    );
  }
}