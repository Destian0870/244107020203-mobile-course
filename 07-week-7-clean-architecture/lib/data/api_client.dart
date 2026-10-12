import 'package:dio/dio.dart';
import 'auth_repository.dart';
import 'token_store.dart';

const _retriedKey = 'retried_after_refresh';

Dio buildApiClient(
  TokenStore store,
  AuthRepository auth, {
  void Function()? onSessionExpired,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example-campus-api.test'));

  Future<void> expireSession() async {
    await store.clear(); // refresh ikut mati -> paksa login ulang
    onSessionExpired?.call(); // beri tahu authStateProvider
  }

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final access = await store.readAccess();
      if (access != null) {
        options.headers['Authorization'] = 'Bearer $access';
      }
      handler.next(options);
    },
    onError: (e, handler) async {
      // Selain 401: teruskan apa adanya (timeout, offline, dll).
      if (e.response?.statusCode != 401) return handler.next(e);

      // Sudah di-retry sekali dan tetap 401 -> sesi tidak valid.
      if (e.requestOptions.extra[_retriedKey] == true) {
        await expireSession();
        return handler.next(e);
      }

      final refresh = await store.readRefresh();
      if (refresh == null || refresh.isEmpty) {
        await expireSession();
        return handler.next(e);
      }

      // 1) Refresh. Hanya kegagalan di sini yang menghapus sesi.
      final String renewed;
      try {
        renewed = await auth.refresh(refresh);
      } catch (_) {
        await expireSession();
        return handler.next(e);
      }
      await store.save(access: renewed, refresh: refresh);

      // 2) Ulangi request SEKALI dengan penanda.
      try {
        final opts = e.requestOptions;
        opts.headers['Authorization'] = 'Bearer $renewed';
        opts.extra[_retriedKey] = true;
        final retry = await dio.fetch(opts);
        return handler.resolve(retry);
      } on DioException catch (retryError) {
        // Gagal karena sebab lain (timeout/offline): jangan logout.
        return handler.next(retryError);
      }
    },
  ));

  return dio;
}