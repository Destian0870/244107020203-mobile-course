import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'messaging/push_service.dart';
import 'providers/auth_provider.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/announcement_page.dart';
import 'routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  registerBackgroundHandler(); // wajib sebelum runApp
  await initLocalNotifications();

  runApp(const ProviderScope(child: MyApp()));
}

// Router dibuat SEKALI. Perubahan status login hanya memicu redirect
// lewat refreshListenable, bukan membuat GoRouter baru.
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authStateProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    refreshListenable: refresh,
    redirect: (context, state) {
      final loggedIn = ref.read(authStateProvider).value ?? false;
      final goingLogin = state.matchedLocation == AppRoutes.login;

      if (!loggedIn && !goingLogin) return AppRoutes.login;
      if (loggedIn && goingLogin) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (_, _) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (_, _) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.pengumuman,
        builder: (_, s) =>
            AnnouncementPage(id: s.pathParameters['id'] ?? ''),
      ),
    ],
  );
});

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final router = ref.read(routerProvider);

      Future<void> go(String route) async {
        // Tunggu status login selesai dimuat, supaya tujuan tidak hilang
        // karena redirect ke /login.
        await ref.read(authStateProvider.future);

        // Normalisasi lewat fungsi murni yang sama dengan yang di-test.
        final path = routeFromMessage({'route': route});
        debugPrint('NAVIGASI ke: $path'); // log sementara
        router.push(path);
      }

      listenForeground(go);   // foreground + background->klik
      handleTerminated(go);   // terminated
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.read(routerProvider);
    return MaterialApp.router(
      routerConfig: router,
      title: 'Campus Notify',
    );
  }
}