// shimmer_box.dart
// A reusable widget for displaying a loading skeleton (shimmer effect).
// Used to indicate loading state before real data is shown, similar to YouTube's loading placeholders.

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerBox extends StatelessWidget {
  final double height;
  final double width;
  final BorderRadius borderRadius;

  const ShimmerBox({super.key, this.height = 16, this.width = double.infinity, this.borderRadius = const BorderRadius.all(Radius.circular(8))});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[700]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[500]! : Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF23262F) : Colors.white,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}
