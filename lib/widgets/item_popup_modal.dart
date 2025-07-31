import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class ItemPopupModal extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String description;

  const ItemPopupModal({
    super.key,
    this.imageUrl,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: defaultTextColor,
            ),
          ),
          const SizedBox(height: 10),
          if (imageUrl != null && imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: Icon(Icons.broken_image, size: 50, color: Colors.grey[600]),
                ),
              ),
            ),
          const SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  IconButton(
                    icon: Icon(Icons.favorite_border, color: defaultTextColor),
                    onPressed: () {
                      // Handle like
                    },
                  ),
                  Text('salute', style: TextStyle(color: secondaryTextColor)),
                ],
              ),
              Column(
                children: [
                  IconButton(
                    icon: Icon(Icons.comment_outlined, color: defaultTextColor),
                    onPressed: () {
                      // Handle comment
                    },
                  ),
                  Text('comment', style: TextStyle(color: secondaryTextColor)),
                ],
              ),
              Column(
                children: [
                  IconButton(
                    icon: Icon(Icons.share, color: defaultTextColor),
                    onPressed: () {
                      // Handle share
                    },
                  ),
                  Text('share', style: TextStyle(color: secondaryTextColor)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}