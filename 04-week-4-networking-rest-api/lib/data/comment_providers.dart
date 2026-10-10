import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'comment.dart';
import 'repositories/comment_repository.dart';
import 'providers.dart';

// Provider untuk CommentRepository
final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => CommentRepository(ref.watch(dioProvider)),
);

// Menggunakan AsyncNotifierProvider standar tanpa family agar aman dari error tipe
final commentListProvider = AsyncNotifierProvider<CommentListNotifier, List<Comment>>(
  CommentListNotifier.new,
);

class CommentListNotifier extends AsyncNotifier<List<Comment>> {
  @override
  Future<List<Comment>> build() async {
    // Default kosong atau bisa diisi pre-load jika perlu
    return [];
  }

  // Method untuk mengambil komentar berdasarkan postId
  Future<void> fetchComments(int postId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(commentRepositoryProvider);
      return repository.fetchComments(postId);
    });
  }

  Future<void> refresh(int postId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(commentRepositoryProvider);
      return repository.fetchComments(postId);
    });
  }
}

// Fungsi helper penerjemah error Dio khusus komentar
String friendlyCommentErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi lambat atau timeout (10 detik). Periksa internet Anda.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Periksa jaringan Anda.';
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        if (code == 404) return 'Data komentar tidak ditemukan (404).';
        if (code == 500) return 'Terjadi kesalahan pada server (500). Coba lagi nanti.';
        return 'Server bermasalah ($code).';
      default:
        return 'Terjadi kesalahan jaringan yang tidak diketahui.';
    }
  }
  return 'Terjadi kesalahan tak terduga: $error';
}