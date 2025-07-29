import 'dart:async';
import '../models/notification.dart';
import '../models/user.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final StreamController<List<NotificationItem>> _notificationsController =
      StreamController<List<NotificationItem>>.broadcast();

  Stream<List<NotificationItem>> get notificationsStream => _notificationsController.stream;

  // Dummy users for notifications
  final List<User> _dummyUsers = [
    User(
      id: 1,
      username: 'john_doe',
      password: '',
      email: 'john@example.com',
      role: 'user',
      fullName: 'John Doe',
      profileImageUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
    ),
    User(
      id: 2,
      username: 'jane_smith',
      password: '',
      email: 'jane@example.com',
      role: 'user',
      fullName: 'Jane Smith',
      profileImageUrl: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face',
    ),
    User(
      id: 3,
      username: 'mike_wilson',
      password: '',
      email: 'mike@example.com',
      role: 'user',
      fullName: 'Mike Wilson',
      profileImageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
    ),
    User(
      id: 4,
      username: 'sarah_jones',
      password: '',
      email: 'sarah@example.com',
      role: 'user',
      fullName: 'Sarah Jones',
      profileImageUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face',
    ),
    User(
      id: 5,
      username: 'david_brown',
      password: '',
      email: 'david@example.com',
      role: 'user',
      fullName: 'David Brown',
      profileImageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&h=150&fit=crop&crop=face',
    ),
    User(
      id: 6,
      username: 'emma_davis',
      password: '',
      email: 'emma@example.com',
      role: 'user',
      fullName: 'Emma Davis',
      profileImageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&h=150&fit=crop&crop=face',
    ),
    User(
      id: 7,
      username: 'alex_taylor',
      password: '',
      email: 'alex@example.com',
      role: 'user',
      fullName: 'Alex Taylor',
      profileImageUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150&h=150&fit=crop&crop=face',
    ),
    User(
      id: 8,
      username: 'lisa_garcia',
      password: '',
      email: 'lisa@example.com',
      role: 'user',
      fullName: 'Lisa Garcia',
      profileImageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&h=150&fit=crop&crop=face',
    ),
  ];

  // Dummy celebrity users
  final List<User> _dummyCelebrities = [
    User(
      id: 101,
      username: 'celebrity_1',
      password: '',
      email: 'celeb1@example.com',
      role: 'celebrity',
      fullName: 'Celebrity One',
      profileImageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
    ),
    User(
      id: 102,
      username: 'celebrity_2',
      password: '',
      email: 'celeb2@example.com',
      role: 'celebrity',
      fullName: 'Celebrity Two',
      profileImageUrl: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face',
    ),
    User(
      id: 103,
      username: 'celebrity_3',
      password: '',
      email: 'celeb3@example.com',
      role: 'celebrity',
      fullName: 'Celebrity Three',
      profileImageUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
    ),
  ];

  List<NotificationItem> _notifications = [];

  bool _isMuted = false;

  bool get isMuted => _isMuted;

  void toggleMute() {
    _isMuted = !_isMuted;
    _notificationsController.add(_notifications);
  }

  Future<void> loadNotifications() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    _notifications = [
      // Follow notifications
      NotificationItem(
        id: '1',
        type: NotificationType.follow,
        user: _dummyUsers[0],
        message: 'started following you',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        status: NotificationStatus.unread,
      ),
      NotificationItem(
        id: '2',
        type: NotificationType.follow,
        user: _dummyUsers[1],
        message: 'started following you',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        status: NotificationStatus.unread,
      ),
      NotificationItem(
        id: '3',
        type: NotificationType.follow,
        user: _dummyUsers[2],
        message: 'started following you',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        status: NotificationStatus.read,
      ),

      // Recelebration notifications
      NotificationItem(
        id: '4',
        type: NotificationType.recelebration,
        user: _dummyUsers[3],
        message: 'recelebrated your post',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        status: NotificationStatus.unread,
        postId: 'post_1',
        postImageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=300&h=200&fit=crop',
        recelebrationText: 'Amazing post! 🔥',
      ),
      NotificationItem(
        id: '5',
        type: NotificationType.recelebration,
        user: _dummyUsers[4],
        message: 'recelebrated your post',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        status: NotificationStatus.read,
        postId: 'post_2',
        postImageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=300&h=200&fit=crop',
        recelebrationText: 'Love this! ❤️',
      ),

      // Celebrity recommendation notifications
      NotificationItem(
        id: '6',
        type: NotificationType.celebrityRecommendation,
        user: _dummyCelebrities[0],
        message: 'You might like this celebrity',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        status: NotificationStatus.unread,
        metadata: {
          'occupation': 'Actor',
          'followers': '2.5M',
          'category': 'Entertainment',
        },
      ),
      NotificationItem(
        id: '7',
        type: NotificationType.celebrityRecommendation,
        user: _dummyCelebrities[1],
        message: 'You might like this celebrity',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        status: NotificationStatus.unread,
        metadata: {
          'occupation': 'Musician',
          'followers': '1.8M',
          'category': 'Music',
        },
      ),
      NotificationItem(
        id: '8',
        type: NotificationType.celebrityRecommendation,
        user: _dummyCelebrities[2],
        message: 'You might like this celebrity',
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
        status: NotificationStatus.read,
        metadata: {
          'occupation': 'Athlete',
          'followers': '3.2M',
          'category': 'Sports',
        },
      ),

      // Post update notifications
      NotificationItem(
        id: '9',
        type: NotificationType.postUpdate,
        user: _dummyCelebrities[0],
        message: 'posted a new update',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        status: NotificationStatus.unread,
        postId: 'post_3',
        postImageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=300&h=200&fit=crop',
      ),
      NotificationItem(
        id: '10',
        type: NotificationType.postUpdate,
        user: _dummyCelebrities[1],
        message: 'posted a new update',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        status: NotificationStatus.read,
        postId: 'post_4',
        postImageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=300&h=200&fit=crop',
      ),
    ];

    _notificationsController.add(_notifications);
  }

  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((notification) => notification.id == notificationId);
    if (index != -1) {
      _notifications[index] = NotificationItem(
        id: _notifications[index].id,
        type: _notifications[index].type,
        user: _notifications[index].user,
        message: _notifications[index].message,
        timestamp: _notifications[index].timestamp,
        status: NotificationStatus.read,
        postId: _notifications[index].postId,
        postImageUrl: _notifications[index].postImageUrl,
        recelebrationText: _notifications[index].recelebrationText,
        metadata: _notifications[index].metadata,
      );
      _notificationsController.add(_notifications);
    }
  }

  Future<void> markAllAsRead() async {
    _notifications = _notifications.map((notification) => NotificationItem(
      id: notification.id,
      type: notification.type,
      user: notification.user,
      message: notification.message,
      timestamp: notification.timestamp,
      status: NotificationStatus.read,
      postId: notification.postId,
      postImageUrl: notification.postImageUrl,
      recelebrationText: notification.recelebrationText,
      metadata: notification.metadata,
    )).toList();
    _notificationsController.add(_notifications);
  }

  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((notification) => notification.id == notificationId);
    _notificationsController.add(_notifications);
  }

  List<NotificationItem> getNotifications() {
    return _notifications;
  }

  int get unreadCount {
    return _notifications.where((notification) => notification.status == NotificationStatus.unread).length;
  }

  void dispose() {
    _notificationsController.close();
  }
} 