import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl; // Nullable, as it might not be provided
  final double radius; // Allows customization of size
  final Color? backgroundColor; // New: Optional custom background color

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.radius = 24.0, // Default radius
    this.backgroundColor, // New: Initialize the new parameter
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      // Use the provided backgroundColor, or default to Colors.grey[200]
      backgroundColor: backgroundColor ?? Colors.grey[200],
      child: ClipOval(
        // Ensures the image is perfectly clipped to a circle
        child: SizedBox.expand(
          // Make the image fill the CircleAvatar's available space
          child: (imageUrl != null && imageUrl!.isNotEmpty)
              ? Image.network(
            imageUrl!,
            fit: BoxFit.cover, // Ensure the image covers the entire circle
            errorBuilder: (context, error, stackTrace) {
              debugPrint(
                  'Error loading profile image from URL: $imageUrl\nException: $error');
              // Fallback to the asset placeholder image on error
              return Image.asset(
                'assets/images/profile_placeholder.png',
                fit: BoxFit.cover,
              );
            },
          )
              : // If imageUrl is null or empty, directly show the asset placeholder
          Image.asset(
            'assets/images/profile_placeholder.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}