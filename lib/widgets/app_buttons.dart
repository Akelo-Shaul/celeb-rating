import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? const Color(
              0xFFD6AF0C),
          // backgroundColor: backgroundColor ?? (isDark ? const Color(0xFF181A20) : const Color(
          //     0xFF7B6509)),
          disabledBackgroundColor: (backgroundColor ?? (isDark ? const Color(0xFF181A20) : const Color(0xFFFCD535))).withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 2.5,
          ),
        )
            : Text(
          text.toUpperCase(),
          style: TextStyle(
            color: textColor ?? (isDark ? Colors.white : Colors.black),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}


class AppTransparentButton extends StatelessWidget {
  final String text;
  final IconData? icon; // Optional icon
  final VoidCallback? onPressed;
  final Color? iconColor; // Customizable icon color only
  final BorderRadiusGeometry? borderRadius; // Customizable border radius
  final EdgeInsetsGeometry? padding; // Customizable padding
  final double? fontSize; // Customizable font size for text

  const AppTransparentButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.iconColor,
    this.borderRadius,
    this.padding,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = isDark ? Colors.white : Colors.black;
    final defaultIconColor = isDark ? Colors.white : Colors.black;

    final BorderRadius resolvedBorderRadius = borderRadius is BorderRadius
        ? borderRadius as BorderRadius
        : BorderRadius.circular(8);

    return Material(
      color: Colors.transparent,
      borderRadius: resolvedBorderRadius,
      child: InkWell(
        onTap: onPressed,
        borderRadius: resolvedBorderRadius,
        child: Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: iconColor ?? defaultIconColor, // Only iconColor is adjustable
                  size: fontSize ?? 28,
                ),
                const SizedBox(width: 20),
              ],
              Text(
                text,
                style: TextStyle(
                  color: defaultTextColor, // Always theme-based
                  fontSize: fontSize ?? 25,
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


class ResizableButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width; // New: Optional width for the button
  final double? height; // New: Optional height for the button
  final EdgeInsetsGeometry? padding; // New: Optional padding for the button's content

  const ResizableButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width, // Initialize new parameter
    this.height, // Initialize new parameter
    this.padding, // Initialize new parameter
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color effectiveBackgroundColor = backgroundColor ?? const Color(0xFFD6AF0C);
    // final Color effectiveBackgroundColor = backgroundColor ?? (isDark ? const Color(0xFF181A20) : const Color(0xFFD6AF0C));

    final Color effectiveTextColor = textColor ?? (isDark ? Colors.white : Colors.black);

    // Determine the effective disabled background color
    final Color effectiveDisabledBackgroundColor = effectiveBackgroundColor.withOpacity(0.6);

    // Determine the child widget (loading indicator or text)
    final Widget buttonChild = isLoading
        ? const SizedBox(
      height: 24, // Consistent size for the loading indicator
      width: 24,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // Assuming white for loading
        strokeWidth: 2.5,
      ),
    )
        : Text(
      text.toUpperCase(),
      style: TextStyle(
        color: effectiveTextColor,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );

    return SizedBox(
      // If width is provided, use it. Otherwise, default to double.infinity.
      width: width ?? double.infinity,
      // If height is provided, use it. Otherwise, default to 50.
      height: height ?? 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBackgroundColor,
          disabledBackgroundColor: effectiveDisabledBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          // If padding is provided, use it. Otherwise, let ElevatedButton default.
          padding: padding,
        ),
        child: buttonChild,
      ),
    );
  }
}

class PostActionButton extends StatelessWidget {
  final IconData icon; // Required icon for the button
  final String? text; // Now truly optional (e.g., "Like", "Comment", or a count like "34")
  final VoidCallback onPressed;
  final bool isSelected; // To indicate if the button is active/selected (e.g., liked)
  final Color? activeIconColor; // Custom color when selected/active
  final Color? inactiveIconColor; // Custom color when not selected/inactive
  final Color? activeTextColor; // Custom text color when selected/active
  final Color? inactiveTextColor; // Custom text color when not selected/inactive
  final Color? activeBackgroundColor; // Custom background color when selected/active
  final Color? inactiveBackgroundColor; // Custom background color when not selected/inactive

  const PostActionButton({
    super.key,
    required this.icon,
    this.text, // Made optional by removing 'required'
    required this.onPressed,
    this.isSelected = false, // Default to not selected
    this.activeIconColor,
    this.inactiveIconColor,
    this.activeTextColor,
    this.inactiveTextColor,
    this.activeBackgroundColor,
    this.inactiveBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine colors based on selection state and theme
    final Color currentIconColor = isSelected
        ? (activeIconColor ?? (isDark ? Colors.blue.shade300 : Colors.blue)) // Default active blue
        : (inactiveIconColor ?? (isDark ? Colors.grey.shade400 : Colors.grey.shade700)); // Default inactive grey

    final Color currentTextColor = isSelected
        ? (activeTextColor ?? (isDark ? Colors.blue.shade300 : Colors.blue)) // Default active blue
        : (inactiveTextColor ?? (isDark ? Colors.grey.shade400 : Colors.grey.shade700)); // Default inactive grey

    final Color currentBackgroundColor = isSelected
        ? (activeBackgroundColor ?? (isDark ? Colors.blue.withOpacity(0.2) : Colors.blue.withOpacity(0.1))) // Light blue fill
        : (inactiveBackgroundColor ?? (isDark ? Colors.transparent : Colors.transparent)); // Transparent for inactive

    return Material(
      color: currentBackgroundColor,
      borderRadius: BorderRadius.circular(20), // Pill shape
      clipBehavior: Clip.antiAlias, // Ensures content respects rounded corners
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), // Adjust padding as needed
          child: Row(
            mainAxisSize: MainAxisSize.min, // Only take up space needed by children
            children: [
              Icon(
                icon,
                color: currentIconColor,
                size: 20, // Adjust icon size to match image
              ),
              // Conditionally add SizedBox and Text only if 'text' is provided
              if (text != null && text!.isNotEmpty) ...[ // Check for null AND empty string
                const SizedBox(width: 6), // Small space between icon and text
                Text(
                  text!, // Safe to use '!' here because of the 'if' check
                  style: TextStyle(
                    color: currentTextColor,
                    fontSize: 14, // Adjust text size as needed
                    fontWeight: FontWeight.w500, // Slightly bold
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AppTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final TextStyle? textStyle; // Optional: allow overriding the default style
  final Color? textColor; // Optional: for setting text color easily

  const AppTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.textStyle,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    // Define the default text style as per your request
    final TextStyle defaultTextStyle = TextStyle(
      fontWeight: FontWeight.w900,
      fontSize: 18,
    );

    return TextButton(
      onPressed: onPressed,
      child: Text(
        text, // Capitalize the text
        style: textStyle ?? defaultTextStyle, // Use custom style if provided, otherwise default
      ),
    );
  }
}
