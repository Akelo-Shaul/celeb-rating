// models/comment.dart
import 'user.dart';

class Comment {
  final String id;
  final User user;
  final String content;
  final int likes; // Count of likes for this specific comment
  final List<Comment> replies; // Replies are just nested comments

  Comment({
    required this.id,
    required this.user,
    required this.content,
    this.likes = 0, // Default likes to 0
    required this.replies,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    id: json['id'] as String,
    user: User.fromJson(json['user'] as Map<String, dynamic>),
    content: json['content'] as String,
    likes: json['likes'] as int? ?? 0, // Default to 0 if not present
    replies: (json['replies'] as List<dynamic>?)
        ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
        .toList() ??
        [], // Recursively parse replies as comments
  );
}