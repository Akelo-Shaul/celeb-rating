import 'package:celebrating/models/comment.dart';
import 'package:celebrating/models/user.dart';

class CommentService {
  static Future<Comment> postComment({
    required String postId,
    required String content,
    required User user,
    Comment? replyingTo,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      user: user,
      content: content.trim(),
      likes: 0,
      replies: [],
    );
    // In a real app, you would send this to a backend and get a response
    return newComment;
  }
}
