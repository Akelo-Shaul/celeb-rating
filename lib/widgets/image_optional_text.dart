import 'package:flutter/material.dart';

class ImageWithOptionalText extends StatelessWidget {
  final double height;
  final double width;
  final String? imageUrl; // Optional image URL
  final String? bottomText; // Optional text to display at the bottom
  final BoxFit fit; // How the image should be fitted in its box

  const ImageWithOptionalText({
    Key? key,
    this.height = 100.0, // Default height
    this.width = 80.0, // Default width
    this.imageUrl,
    this.bottomText,
    this.fit = BoxFit.cover, // Default fit for the image
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine the image widget to use (network or fallback asset)
    final Widget imageContent;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      imageContent = Image.network(
        imageUrl!,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading image from URL: $imageUrl\nException: $error');
          return Image.asset(
            'assets/images/profile_placeholder.jpg',
            fit: BoxFit.cover,
          );
        },
      );
    } else {
      imageContent = Image.asset(
        'assets/images/profile_placeholder.jpg',
        fit: BoxFit.cover,
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = isDark ? Colors.white : Colors.black;
    final cardColor = Theme.of(context).cardColor; // Or a specific background color

    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: width,
            height: height,
            color: cardColor,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageContent,
            ),
          ),
          if (bottomText != null && bottomText!.isNotEmpty)
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  bottomText!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: defaultTextColor,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }
}