import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl; // Nullable, as it might not be provided
  final double radius; // Allows customization of size
  final Widget? fallbackWidget; // Optional custom fallback widget

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.radius = 24.0, // Default radius as in your example
    this.fallbackWidget, // Optional custom fallback
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[200],
      backgroundImage: (imageUrl != null && imageUrl!.isNotEmpty)
          ? NetworkImage(imageUrl!)
          : const AssetImage('assets/images/profile_placeholder.jpg') as ImageProvider,
      onBackgroundImageError: (exception, stackTrace) {
        debugPrint('Error loading profile image from URL: $imageUrl\nException: $exception');
      },
      child: (imageUrl == null || imageUrl!.isEmpty)
          ? (fallbackWidget ?? Icon(Icons.person, size: radius * 1.2, color: Colors.grey[400]))
          : null,
    );
  }
}