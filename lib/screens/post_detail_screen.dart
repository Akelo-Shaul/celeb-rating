import 'package:flutter/material.dart';
import '../models/post.dart';
import '../widgets/post_card.dart';

class PostDetailScreen extends StatelessWidget {
  final Post post;
  final List<Post> suggestedPosts;
  const PostDetailScreen({super.key, required this.post, required this.suggestedPosts});

  @override
  Widget build(BuildContext context) {
    // Combine the current post and suggested posts into one list
    final List<Post> allPosts = [post, ...suggestedPosts];
    return Scaffold(
      appBar: AppBar(title: const Text('Post Detail')),
      body: ListView.builder(
        itemCount: allPosts.length,
        itemBuilder: (context, i) {
          return PostCard(post: allPosts[i]);
        },
      ),
    );
  }
}
