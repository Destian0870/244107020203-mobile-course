import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatsNotifier extends AsyncNotifier<List<String>> {
  final Random _random;
  final Duration delay;

  // Menerima parameter mock Random dan Duration dari unit test
  StatsNotifier([Random? random, this.delay = const Duration(seconds: 2)])
      : _random = random ?? Random();

  @override
  Future<List<String>> build() async {
    return _fetchStats();
  }

  Future<List<String>> _fetchStats() async {
    if (delay != Duration.zero) {
      await Future.delayed(delay);
    }

    if (_random.nextDouble() < 0.3) {
      throw Exception('Gagal mengambil data statistik (Simulasi Error 30%)');
    }

    return const [
      'Total Pengguna: 1,250',
      'Penjualan Bulanan: Rp 45.000.000',
      'Rating Aplikasi: 4.8 / 5.0',
    ];
  }
}

final statsProvider =
    AsyncNotifierProvider<StatsNotifier, List<String>>(
  StatsNotifier.new,
);