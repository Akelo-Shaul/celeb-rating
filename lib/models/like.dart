// models/like.dart
import 'user.dart'; // Assuming you have a User model, or simple string for now

class Like {
  final String userId; // The ID of the user who liked it
  final DateTime likedAt; // When the like occurred (optional but useful)

  Like({
    required this.userId,
    required this.likedAt,
  });

  factory Like.fromJson(Map<String, dynamic> json) => Like(
    userId: json['userId'] as String,
    likedAt: DateTime.parse(json['likedAt'] as String),
  );
}