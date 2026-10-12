import 'package:dio/dio.dart';

/// Memetakan DioException menjadi pesan ramah pengguna.
/// UI hanya menerima String ini, bukan exception mentah.
String pesanError(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'Koneksi lambat, coba lagi.';
    case DioExceptionType.connectionError:
      return 'Tidak ada koneksi internet.';
    default:
      break;
  }

  if (e.response?.statusCode == 401) {
    return 'Sesi berakhir, silakan login ulang.';
  }
  return 'Terjadi kesalahan, coba lagi nanti.';
}

/// Exception aplikasi yang hanya membawa pesan ramah pengguna.
class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message; // tampil bersih di UI, tanpa awalan "Exception:"
}