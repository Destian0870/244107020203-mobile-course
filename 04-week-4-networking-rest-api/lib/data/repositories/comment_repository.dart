import 'package:dio/dio.dart';
import '../comment.dart'; // Mundur satu folder ke lib/data/comment.dart

class CommentRepository {
  final Dio _dio;

  CommentRepository(this._dio);

  Future<List<Comment>> fetchComments(int postId) async {
    try {
      final response = await _dio.get(
        'https://jsonplaceholder.typicode.com/comments',
        queryParameters: {'postId': postId},
        options: Options(receiveTimeout: const Duration(seconds: 10)),
      );

      final data = response.data as List;
      return data.map((json) => Comment.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}