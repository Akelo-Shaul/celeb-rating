import 'package:flutter/material.dart';

Future<void> showSlideUpDialog({
  required BuildContext context,
  required Widget child,
  EdgeInsets? padding,
  BorderRadius? borderRadius,
  Color? backgroundColor,
  double? width,
  double? height,
}) {
  return showGeneralDialog(
    context: context,
    // Setting barrierDismissible to true enables dismissal when tapping outside.
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54, // The semi-transparent overlay color
    transitionDuration: const Duration(milliseconds: 300), // Animation speed
    pageBuilder: (context, animation, secondaryAnimation) {
      // This GestureDetector captures taps on the *entire screen area covered by the dialog*,
      // allowing it to dismiss the dialog when taps occur outside the modal content.
      return GestureDetector(
        onTap: () {
          // Explicitly dismiss the dialog when a tap is detected on the barrier.
          Navigator.of(context).pop();
        },
        // Using a Stack to layer the barrier GestureDetector below the actual dialog content.
        child: Stack(
          children: [
            // Align centers the SlideUpDialog on the screen.
            Align(
              alignment: Alignment.center,
              // AbsorbPointer prevents taps on the actual dialog content from propagating
              // to the barrier GestureDetector. This ensures that interactive elements
              // inside your dialog (like buttons) still work.
              // 'absorbing: false' means it does NOT absorb pointer events itself,
              // allowing them to pass through to its child (SlideUpDialog).
              child: AbsorbPointer(
                absorbing: false, // Important: allows interaction within the dialog
                child: SlideUpDialog(
                  padding: padding,
                  borderRadius: borderRadius,
                  backgroundColor: backgroundColor,
                  width: width,
                  height: height,
                  child: child, // The content you want to display in the dialog
                ),
              ),
            ),
          ],
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      // Defines the slide-up animation effect.
      const begin = Offset(0.0, 1.0); // Starts from the bottom
      const end = Offset.zero; // Ends at its final position
      final tween = Tween(begin: begin, end: end);
      final offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: FadeTransition( // Optional: Adds a fade-in effect along with the slide.
          opacity: animation,
          child: child,
        ),
      );
    },
  );
}

/// A custom dialog widget that displays its content within a Material card
/// with rounded corners and customizable dimensions.
class SlideUpDialog extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final double? width;
  final double? height;

  const SlideUpDialog({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(20.0),
    this.borderRadius = const BorderRadius.all(Radius.circular(16.0)),
    this.backgroundColor,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent, // Makes the default Dialog background transparent
      insetPadding: EdgeInsets.zero, // Removes default padding around the dialog
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: Material(
              color: backgroundColor ?? Theme.of(context).cardColor, // Dialog's background color
              borderRadius: borderRadius,
              clipBehavior: Clip.antiAlias, // Ensures content is clipped to the rounded corners
              child: SizedBox(
                width: width ?? constraints.maxWidth * 0.8, // Customizable width
                height: height, // Customizable height
                child: Padding(
                  padding: padding ?? const EdgeInsets.all(20.0),
                  child: child, // The content of the dialog
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}