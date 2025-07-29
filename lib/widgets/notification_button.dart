import 'package:flutter/material.dart';
import 'package:celebrating/services/notification_service.dart';

class NotificationButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onPressed;
  final double? fontSize;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final Color? iconColor;

  const NotificationButton({
    super.key,
    required this.text,
    required this.icon,
    this.onPressed,
    this.fontSize,
    this.padding,
    this.borderRadius,
    this.iconColor,
  });

  @override
  State<NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<NotificationButton> {
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
    final defaultTextColor = isDark ? Colors.white : Colors.black;
    final defaultIconColor = isDark ? Colors.white : Colors.black;

    final BorderRadius resolvedBorderRadius = widget.borderRadius ?? BorderRadius.circular(8);

    return Material(
      color: Colors.transparent,
      borderRadius: resolvedBorderRadius,
      child: InkWell(
        onTap: widget.onPressed,
        borderRadius: resolvedBorderRadius,
        child: Padding(
          padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Icon(
                    widget.icon,
                    color: widget.iconColor ?? defaultIconColor,
                    size: widget.fontSize ?? 28,
                  ),
                  if (_unreadCount > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? Colors.black : Colors.white,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 20),
              Text(
                widget.text,
                style: TextStyle(
                  color: defaultTextColor,
                  fontSize: widget.fontSize ?? 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 