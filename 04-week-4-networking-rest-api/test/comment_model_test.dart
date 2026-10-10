import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/comment.dart'; // Sesuaikan nama package project Anda

void main() {
  group('Comment Model Test', () {
    test('fromJson berhasil memparsing JSON normal dengan benar', () {
      final json = {
        'postId': 1,
        'id': 10,
        'name': 'Test Name',
        'email': 'test@example.com',
        'body': 'Test body content',
      };

      final comment = Comment.fromJson(json);

      expect(comment.postId, 1);
      expect(comment.id, 10);
      expect(comment.name, 'Test Name');
      expect(comment.email, 'test@example.com');
      expect(comment.body, 'Test body content');
    });

    test('fromJson menangani field yang hilang atau bernilai null dengan fallback yang aman (Edge Case)', () {
      // JSON dengan field tidak lengkap / null untuk menguji robustness
      final Map<String, dynamic> incompleteJson = {
        'postId': null,
        // 'id' sengaja dihilangkan
        'name': null,
        // 'email' sengaja dihilangkan
        'body': 'Hanya body yang ada',
      };

      final comment = Comment.fromJson(incompleteJson);

      expect(comment.postId, 0); // fallback default
      expect(comment.id, 0);     // fallback default
      expect(comment.name, '');  // fallback default string kosong
      expect(comment.email, ''); // fallback default string kosong
      expect(comment.body, 'Hanya body yang ada');
    });
  });
}