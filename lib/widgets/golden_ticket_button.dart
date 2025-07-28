import 'package:flutter/material.dart';

class GoldenTicketButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double height;
  final Color color;
  final Color textColor;

  const GoldenTicketButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.height = 48,
    this.color = const Color(0xFFD8AF16),
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: CustomPaint(
        painter: _TicketCornerNotchPainter(color: color),
        child: Container(
          height: height,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            text.toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _TicketCornerNotchPainter extends CustomPainter {
  final Color color;

  _TicketCornerNotchPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    final notchRadius = size.height * 0.24;

    // Start just right of top-left notch
    path.moveTo(0, notchRadius);
    // Top left notch (inward)
    path.arcToPoint(
      Offset(notchRadius, 0),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );
    // Top edge
    path.lineTo(size.width - notchRadius, 0);
    // Top right notch (inward)
    path.arcToPoint(
      Offset(size.width, notchRadius),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );
    // Right edge
    path.lineTo(size.width, size.height - notchRadius);
    // Bottom right notch (inward)
    path.arcToPoint(
      Offset(size.width - notchRadius, size.height),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );
    // Bottom edge
    path.lineTo(notchRadius, size.height);
    // Bottom left notch (inward)
    path.arcToPoint(
      Offset(0, size.height - notchRadius),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );
    // Left edge
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TicketCornerNotchPainter oldDelegate) =>
      oldDelegate.color != color;
}