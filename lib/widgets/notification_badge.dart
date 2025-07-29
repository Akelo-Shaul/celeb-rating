import 'package:flutter/material.dart';
import 'package:celebrating/services/notification_service.dart';

class NotificationBadge extends StatefulWidget {
  final Widget child;
  final double? size;
  final Color? backgroundColor;
  final Color? textColor;

  const NotificationBadge({
    super.key,
    required this.child,
    this.size,
    this.backgroundColor,
    this.textColor,
  });

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> {
  final NotificationService _notificationService = NotificationService();
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _notificationService.notificationsStream.listen((notifications) {
      setState(() {
        _unreadCount = _notificationService.unreadCount;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Stack(
      children: [
        widget.child,
        if (_unreadCount > 0)
          Positioned(
            right: 8, // Position it more towards the icon
            top: 8,   // Position it more towards the icon
            child: Container(
              width: widget.size ?? 16,
              height: widget.size ?? 16,
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? Colors.red,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? Colors.black : Colors.white,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                  style: TextStyle(
                    color: widget.textColor ?? Colors.white,
                    fontSize: (widget.size ?? 16) * 0.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
} 