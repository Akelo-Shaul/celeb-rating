import 'user.dart';

enum NotificationType {
  follow,
  recelebration,
  celebrityRecommendation,
  postUpdate,
}

enum NotificationStatus {
  unread,
  read,
}

class NotificationItem {
  final String id;
  final NotificationType type;
  final User user;
  final String message;
  final DateTime timestamp;
  final NotificationStatus status;
  final String? postId;
  final String? postImageUrl;
  final String? recelebrationText;
  final Map<String, dynamic>? metadata;

  NotificationItem({
    required this.id,
    required this.type,
    required this.user,
    required this.message,
    required this.timestamp,
    this.status = NotificationStatus.unread,
    this.postId,
    this.postImageUrl,
    this.recelebrationText,
    this.metadata,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${json['type']}',
      ),
      user: User.fromJson(json['user']),
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      status: NotificationStatus.values.firstWhere(
        (e) => e.toString() == 'NotificationStatus.${json['status']}',
      ),
      postId: json['postId'],
      postImageUrl: json['postImageUrl'],
      recelebrationText: json['recelebrationText'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'user': user.toJson(),
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'status': status.toString().split('.').last,
      'postId': postId,
      'postImageUrl': postImageUrl,
      'recelebrationText': recelebrationText,
      'metadata': metadata,
    };
  }
} 