import 'package:flutter/material.dart';
import 'dart:ui' as ui; // For Shader and ImageFilter if needed for advanced effects

class PartedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final double height;
  final String leftText;
  final String rightText;
  final Color leftTextColor;
  final Color rightTextColor;
  final Color leftBackgroundColor;
  final Color rightBackgroundColor;
  final double borderRadius;
  final double partitionCurveDepth; // New parameter to control the curve's 'S' shape intensity

  const PartedButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.height = 48,
    required this.leftText,
    required this.rightText,
    this.leftTextColor = const Color(0xFFD6AF0C), // Default to some distinct colors
    this.rightTextColor = Colors.white,
    this.leftBackgroundColor = Colors.white,
    this.rightBackgroundColor = const Color(0xFFD6AF0C),
    this.borderRadius = 10,
    this.partitionCurveDepth = 5, // Default depth of the curve's 'S' bend
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Material(
        color: Colors.transparent, // Material widget for ink effect, but transparent background
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: isLoading ? null : onPressed, // Disable tap when loading
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Use a CustomPaint for the entire background to draw both colors and the curve
              Positioned.fill(
                child: CustomPaint(
                  painter: _PartedButtonBackgroundPainter(
                    leftBackgroundColor: leftBackgroundColor,
                    rightBackgroundColor: rightBackgroundColor,
                    borderRadius: borderRadius,
                    partitionCurveDepth: partitionCurveDepth,
                  ),
                ),
              ),

              // Texts
              // Use a Row with Flexible/Expanded to distribute text appropriately
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Pushes texts to ends
                  children: [
                    Flexible(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          leftText,
                          style: TextStyle(
                            color: leftTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    SizedBox(width: partitionCurveDepth / 2),
                    Flexible(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          rightText,
                          style: TextStyle(
                            color: rightTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Loading Indicator
              if (isLoading)
                const Center(
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // Assuming white is visible
                      strokeWidth: 2.5,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// CustomPainter to draw the two colored backgrounds and the S-curve partition line
class _PartedButtonBackgroundPainter extends CustomPainter {
  final Color leftBackgroundColor;
  final Color rightBackgroundColor;
  final double borderRadius;
  final double partitionCurveDepth; // Depth of the curve

  _PartedButtonBackgroundPainter({
    required this.leftBackgroundColor,
    required this.rightBackgroundColor,
    required this.borderRadius,
    required this.partitionCurveDepth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Paints for the two sections
    final leftPaint = Paint()..color = leftBackgroundColor;
    final rightPaint = Paint()..color = rightBackgroundColor;
    final partitionLinePaint = Paint()
      ..color = Colors.black // Color of the separating line
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke; // Just the outline for the line

    // Calculate curve points relative to the middle of the button's width
    final double midWidth = size.width / 2;

    // Define points for the S-curve
    // These points will form the boundary
    final p1 = Offset(midWidth - (partitionCurveDepth / 2), 0); // Start of the curve (top-left of "S")
    final c1 = Offset(midWidth + (partitionCurveDepth * 1.5), size.height * 0.25); // Control point 1 (pulls curve right)
    final c2 = Offset(midWidth - (partitionCurveDepth * 1.5), size.height * 0.75); // Control point 2 (pulls curve left)
    final p2 = Offset(midWidth + (partitionCurveDepth / 2), size.height); // End of the curve (bottom-right of "S")

    // Path for the left section
    final leftPath = Path();
    leftPath.moveTo(0, borderRadius); // Start after radius on top-left
    leftPath.arcToPoint(Offset(borderRadius, 0), radius: Radius.circular(borderRadius), clockwise: false); // Top-left corner
    leftPath.lineTo(midWidth - (partitionCurveDepth / 2), 0); // Top straight part to curve start (p1)

    // Add the S-curve segment
    leftPath.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);

    leftPath.lineTo(size.width, size.height - borderRadius); // Bottom-right corner (end of the right section's straight part)
    leftPath.arcToPoint(Offset(size.width - borderRadius, size.height), radius: Radius.circular(borderRadius), clockwise: false); // Bottom-right corner
    leftPath.lineTo(borderRadius, size.height); // Bottom straight part to bottom-left corner
    leftPath.arcToPoint(Offset(0, size.height - borderRadius), radius: Radius.circular(borderRadius), clockwise: false); // Bottom-left corner
    leftPath.lineTo(0, borderRadius); // Left straight part to top-left corner
    leftPath.close();

    // Draw the left section
    canvas.drawPath(leftPath, leftPaint);

    // Now, create the path for the right side by "filling" the other side of the S-curve
    final rightPath = Path();
    rightPath.moveTo(midWidth - (partitionCurveDepth / 2), 0); // Start at the same point as p1
    rightPath.lineTo(size.width - borderRadius, 0); // Top straight part for right section
    rightPath.arcToPoint(Offset(size.width, borderRadius), radius: Radius.circular(borderRadius), clockwise: false); // Top-right corner
    rightPath.lineTo(size.width, size.height - borderRadius); // Right straight part
    rightPath.arcToPoint(Offset(size.width - borderRadius, size.height), radius: Radius.circular(borderRadius), clockwise: false); // Bottom-right corner
    rightPath.lineTo(midWidth + (partitionCurveDepth / 2), size.height); // Bottom straight part to curve end (p2)

    // Add the S-curve segment (reversed direction to close the path for the fill)
    rightPath.cubicTo(c2.dx, c2.dy, c1.dx, c1.dy, p1.dx, p1.dy); // Use control points in reverse order to draw the other side of the S
    rightPath.close();

    // Draw the right section
    canvas.drawPath(rightPath, rightPaint);

    // Finally, draw the S-curve line on top of both fills to define the partition
    final partitionSPath = Path();
    partitionSPath.moveTo(p1.dx, p1.dy);
    partitionSPath.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    canvas.drawPath(partitionSPath, partitionLinePaint);
  }

  @override
  bool shouldRepaint(covariant _PartedButtonBackgroundPainter oldDelegate) {
    return oldDelegate.leftBackgroundColor != leftBackgroundColor ||
        oldDelegate.rightBackgroundColor != rightBackgroundColor ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.partitionCurveDepth != partitionCurveDepth;
  }
}