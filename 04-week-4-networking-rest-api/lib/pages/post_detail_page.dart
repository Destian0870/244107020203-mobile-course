import 'package:flutter/material.dart';
import '../data/models/post.dart';

class PostDetailPage extends StatelessWidget {
  final Post? post;
  final int postId;

  const PostDetailPage({super.key, this.post, required this.postId});

  @override
  Widget build(BuildContext context) {
    // Jika post langsung dibuka via URL/direct route, tampilkan berdasarkan ID atau state
    return Scaffold(
      appBar: AppBar(title: Text('Detail Post #$postId')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: post != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post!.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(post!.body, style: const TextStyle(fontSize: 16)),
                ],
              )
            : Center(child: Text('Memuat detail post ID: $postId...')),
      ),
    );
  }
}