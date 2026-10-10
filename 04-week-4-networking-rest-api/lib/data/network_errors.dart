import 'package:dio/dio.dart';

String friendlyErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi timeout. Periksa jaringan Anda.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server (connection error).';
      case DioExceptionType.badResponse:
        return 'Kesalahan server: ${error.response?.statusCode}';
      default:
        return 'Terjadi kesalahan jaringan.';
    }
  }
  return 'Terjadi kesalahan: $error';
}