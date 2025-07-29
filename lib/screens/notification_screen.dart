import 'package:flutter/material.dart';
import 'package:celebrating/models/notification.dart';
import 'package:celebrating/services/notification_service.dart';
import 'package:celebrating/widgets/profile_avatar.dart';
import 'package:celebrating/widgets/app_buttons.dart';
import 'package:celebrating/widgets/app_text_fields.dart';
import 'package:celebrating/theme/app_theme.dart';
import 'package:celebrating/theme/app_strings.dart';
import 'package:celebrating/l10n/app_localizations.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _notificationService = NotificationService();
  List<NotificationItem> _notifications = [];
  bool _isLoading = true;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _notificationService.notificationsStream.listen((notifications) {
      setState(() {
        _notifications = notifications;
        _isMuted = _notificationService.isMuted;
      });
    });
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    await _notificationService.loadNotifications();

    setState(() {
      _isLoading = false;
    });
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${difference.inDays ~/ 7}w ago';
    }
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUnread = notification.status == NotificationStatus.unread;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isUnread 
            ? (isDark ? Color(0xFFD6AF0C).withOpacity(0.1) : Color(0xFFD6AF0C).withOpacity(0.05))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isDark 
            ? Border.all(color: Colors.grey.withOpacity(0.2))
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Stack(
          children: [
            ProfileAvatar(
              imageUrl: notification.user.profileImageUrl,
              radius: 24,
            ),
            if (isUnread)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6AF0C),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? Colors.black : Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: RichText(
          text: TextSpan(
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 15,
              fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
            ),
            children: [
              TextSpan(
                text: notification.user.fullName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: ' ${notification.message}'),
            ],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              _getTimeAgo(notification.timestamp),
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 12,
              ),
            ),
            if (notification.recelebrationText != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.repeat,
                      size: 16,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        notification.recelebrationText!,
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (notification.postImageUrl != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  notification.postImageUrl!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.image,
                        color: isDark ? Colors.grey[600] : Colors.grey[500],
                      ),
                    );
                  },
                ),
              ),
            ],
            if (notification.type == NotificationType.celebrityRecommendation &&
                notification.metadata != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Color(0xFFD6AF0C).withOpacity(0.1) : Color(0xFFD6AF0C).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: const Color(0xFFD6AF0C),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.metadata!['occupation'] ?? '',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${notification.metadata!['followers']} followers',
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      onSelected: (value) {
                        _handleRecommendationAction(value, notification);
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'more_like_this',
                          child: Row(
                            children: [
                              Icon(Icons.thumb_up),
                              SizedBox(width: 8),
                              Text('More like this'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'less_like_this',
                          child: Row(
                            children: [
                              Icon(Icons.thumb_down),
                              SizedBox(width: 8),
                              Text('Less like this'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'change_preferences',
                          child: Row(
                            children: [
                              Icon(Icons.settings),
                              SizedBox(width: 8),
                              Text('Change preferences'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        trailing: notification.type == NotificationType.follow
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 80,
                    height: 32,
                    child:AppTextButton(
                      text: AppLocalizations.of(context)!.follow,
                      onPressed: () {
                        print('${AppLocalizations.of(context)!.follow} button pressed!');
                        // Add your follow logic here
                      },
                    ),
                  ),
                ],
              )
            : null,
        onTap: () {
          _notificationService.markAsRead(notification.id);
          // Handle navigation based on notification type
          _handleNotificationTap(notification);
        },
      ),
    );
  }

  void _handleRecommendationAction(String action, NotificationItem notification) {
    switch (action) {
      case 'more_like_this':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('We\'ll show you more like this')),
        );
        break;
      case 'less_like_this':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('We\'ll show you less like this')),
        );
        break;
      case 'change_preferences':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opening preferences...')),
        );
        break;
    }
  }

  void _handleNotificationTap(NotificationItem notification) {
    switch (notification.type) {
      case NotificationType.follow:
        // Navigate to user profile
        break;
      case NotificationType.recelebration:
      case NotificationType.postUpdate:
        // Navigate to post detail
        break;
      case NotificationType.celebrityRecommendation:
        // Navigate to celebrity profile
        break;
    }
  }



  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      // backgroundColor: isDark ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        // backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        title: Text(
          'Notifications',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: isDark ? Colors.white : Colors.black,
            ),
            onSelected: (value) {
              switch (value) {
                case 'mark_all_read':
                  _notificationService.markAllAsRead();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All notifications marked as read')),
                  );
                  break;
                case 'toggle_mute':
                  _notificationService.toggleMute();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_mute',
                child: Row(
                  children: [
                    Icon(
                      _isMuted ?  Icons.notifications_off : Icons.notifications,
                      color: _isMuted ? const Color(0xFFD6AF0C) : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(_isMuted ?  'Unmute notifications' : 'Mute notifications'),
                  ],
                ),
              ),
              if (_notifications.isNotEmpty)
                const PopupMenuItem(
                  value: 'mark_all_read',
                  child: Row(
                    children: [
                      Icon(Icons.done_all),
                      SizedBox(width: 8),
                      Text('Mark all as read'),
                    ],
                  ),
                ),
            ],
          ),
        ],
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? Colors.white : const Color(0xFFD6AF0C),
                ),
              ),
            )
                    : Column(
              children: [
                Expanded(
                  child: _notifications.isEmpty
                       ? Center(
                           child: Column(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               Icon(
                                 Icons.notifications_none,
                                 size: 64,
                                 color: isDark ? Colors.grey[600] : Colors.grey[400],
                               ),
                               const SizedBox(height: 16),
                               Text(
                                 'No notifications yet',
                                 style: TextStyle(
                                   color: isDark ? Colors.grey[400] : Colors.grey[600],
                                   fontSize: 18,
                                   fontWeight: FontWeight.w500,
                                 ),
                               ),
                               const SizedBox(height: 8),
                               Text(
                                 'When you get notifications, they\'ll appear here',
                                 style: TextStyle(
                                   color: isDark ? Colors.grey[500] : Colors.grey[500],
                                   fontSize: 14,
                                 ),
                                 textAlign: TextAlign.center,
                               ),
                             ],
                           ),
                         )
                       : RefreshIndicator(
                           onRefresh: _loadNotifications,
                           child: ListView.builder(
                             itemCount: _notifications.length,
                             itemBuilder: (context, index) {
                               return _buildNotificationItem(_notifications[index]);
                             },
                           ),
                         ),
                 ),
              ],
            ),
    );
  }
} 