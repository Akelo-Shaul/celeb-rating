import 'package:flutter/material.dart';

class ImageWithOptionalText extends StatelessWidget {
  final double width;
  final double height;
  final String? imageUrl;
  final String? bottomText;
  final bool isVideo; // New parameter to indicate if the media is a video

  const ImageWithOptionalText({
    super.key,
    required this.width,
    required this.height,
    this.imageUrl,
    this.bottomText,
    this.isVideo = false, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
        image: imageUrl != null && imageUrl!.isNotEmpty && !isVideo
            ? DecorationImage(
          image: NetworkImage(imageUrl!),
          fit: BoxFit.cover,
        )
            : null,
      ),
      child: Stack(
        children: [
          if (imageUrl == null || imageUrl!.isEmpty)
            Center(
              child: Icon(
                isVideo ? Icons.videocam : Icons.image,
                size: 50,
                color: Colors.grey[600],
              ),
            ),
          if (bottomText != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(12)),
                ),
                child: Text(
                  bottomText!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }
}