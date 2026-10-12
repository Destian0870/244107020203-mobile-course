import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../routes.dart';

final _local = FlutterLocalNotificationsPlugin();

// Variabel global untuk menampung payload deep link
String? pendingDeepLink;

// Callback navigasi, diisi oleh listenForeground()
void Function(String route)? _goCallback;

// ---------------------------------------------------------------
// 1. Background handler: WAJIB top-level (bukan method kelas)
// ---------------------------------------------------------------
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Jangan akses BuildContext / Riverpod di sini.
  debugPrint('BG handler: ${message.messageId} data=${message.data}');
}

void registerBackgroundHandler() {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

// ---------------------------------------------------------------
// Permission & local notifications
// ---------------------------------------------------------------
Future<bool> requestNotificationPermission() async {
  final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    announcement: false,
    carPlay: false,
    criticalAlert: false,
  );
  return settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional;
}

Future<void> initLocalNotifications() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings();

  const initializationSettings = InitializationSettings(
    android: android,
    iOS: ios,
  );

  await _local.initialize(
    settings: initializationSettings,
    onDidReceiveNotificationResponse: (response) {
      debugPrint('KLIK banner, payload: ${response.payload}'); // log sementara
      final payload = response.payload;
      if (payload != null && payload.isNotEmpty) {
        // Payload sudah berupa route; normalisasi lewat fungsi murni.
        final route = routeFromMessage({'route': payload});
        if (_goCallback != null) {
          _goCallback!(route);
        } else {
          pendingDeepLink = route;
        }
      }
    },
  );
}

// ---------------------------------------------------------------
// 2. Tiga handler: foreground, background->klik, terminated
// ---------------------------------------------------------------
void listenForeground(void Function(String route) go) {
  _goCallback = go;

  // Foreground: sistem TIDAK menampilkan banner otomatis,
  // jadi tampilkan manual via local notification.
  FirebaseMessaging.onMessage.listen((message) async {
    debugPrint('FOREGROUND diterima: ${message.data}'); // log sementara
    final route = routeFromMessage(message.data);
    const androidDetails = AndroidNotificationDetails(
      'pengumuman',
      'Pengumuman Kampus',
      importance: Importance.high,
      priority: Priority.high,
    );
    await _local.show(
      id: message.hashCode,
      title: message.notification?.title ?? 'Pengumuman',
      body: message.notification?.body ?? '',
      notificationDetails: const NotificationDetails(android: androidDetails),
      payload: route,
    );
  });

  // Background -> diklik.
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    debugPrint('OPENED APP, data: ${message.data}'); // log sementara
    go(routeFromMessage(message.data));
  });
}

Future<void> handleTerminated(void Function(String route) go) async {
  // Terminated -> dibuka dari notifikasi.
  final initial = await FirebaseMessaging.instance.getInitialMessage();
  if (initial != null) go(routeFromMessage(initial.data));
  if (pendingDeepLink != null) {
    go(pendingDeepLink!);
    pendingDeepLink = null;
  }
}

// ---------------------------------------------------------------
// Token lifecycle
// ---------------------------------------------------------------
Future<void> initFcmToken({required Future<void> Function(String token) onToken}) async {
  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) await onToken(token);

  FirebaseMessaging.instance.onTokenRefresh.listen(onToken);

  await FirebaseMessaging.instance.subscribeToTopic('pengumuman-kampus');
}