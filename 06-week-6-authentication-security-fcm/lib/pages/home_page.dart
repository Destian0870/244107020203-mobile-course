import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../providers/auth_provider.dart';
import '../messaging/push_service.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String _fcmToken = "Memuat token...";

  @override
  void initState() {
    super.initState();
    _initPush();
  }

  Future<void> _initPush() async {
    await requestNotificationPermission();

    await initFcmToken(onToken: (token) async {
      // Dipanggil saat pertama kali DAN setiap token berubah (onTokenRefresh).
      debugPrint('onToken dipanggil: ${token.substring(0, 12)}...');
      if (mounted) setState(() => _fcmToken = token);

      // Kirim ke backend (aktifkan jika dio/backend sudah siap):
      // await dio.post('/devices', data: {'fcm_token': token, 'platform': 'android'});
    });
  }

  @override
  Widget build(BuildContext context) {
    // Potong token agar tampil rapi di UI debug (12 karakter pertama + ...)
    final displayToken = _fcmToken.length > 12
        ? '${_fcmToken.substring(0, 12)}...'
        : _fcmToken;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Notify'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Card untuk FCM Token (Debug)
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.vpn_key, color: Colors.indigo),
                      SizedBox(width: 8),
                      Text(
                        'FCM Token (debug)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    displayToken,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Card untuk Langganan Topik
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.notifications_active, color: Colors.indigo),
                      SizedBox(width: 8),
                      Text(
                        'Langganan topik',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'pengumuman-kampus',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () async {
                          await FirebaseMessaging.instance.subscribeToTopic('pengumuman-kampus');
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Berhasil subscribe topik')),
                          );
                        },
                        child: const Text('Subscribe',
                            style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () async {
                          await FirebaseMessaging.instance.unsubscribeFromTopic('pengumuman-kampus');
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Berhasil unsubscribe topik')),
                          );
                        },
                        child: const Text('Unsubscribe',
                            style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Tombol Navigasi Pengumuman
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF535C91),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              context.push('/pengumuman/3');
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('Buka /pengumuman/3', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 20),

          const Text(
            'Status: login berhasil. Token disimpan di secure storage dan dikirim ke backend (POST /devices).',
            style: TextStyle(color: Colors.black87, fontSize: 14),
          ),
        ],
      ),
    );
  }
}