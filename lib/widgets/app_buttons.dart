import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon; // Optional icon before the text

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.backgroundColor,
    this.textColor,
    this.icon, // Add icon to constructor
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool disabled = !isEnabled || isLoading;
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? const Color(0xFFD6AF0C),
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
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: textColor ?? (isDark ? Colors.white : Colors.black)),
                    const SizedBox(width: 10),
                  ],
                  Flexible(
                    child: Text(
                      text.toUpperCase(),
                      style: TextStyle(
                        color: textColor ?? (isDark ? Colors.white : Colors.black),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class AppOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? textColor;

  const AppOutlinedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final outlineColor = const Color(0xFFD6AF0C);
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: outlineColor, width: 2),
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF181A20)),
            strokeWidth: 2.5,
          ),
        )
            : Text(
          text.toUpperCase(),
          style: TextStyle(
            color: textColor ??
                (isDark ? Colors.white : outlineColor),
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


class AppToggleButton extends StatefulWidget {
  final bool isToggled; // Current state of the button
  final ValueChanged<bool> onToggle; // Callback when the button is toggled

  // Untoggled state properties for Icon and Text
  final IconData? untoggledIcon; // Made optional
  final Color? untoggledColor; // Optional icon/text color for untoggled state
  final String? untoggledText; // Optional text for untoggled state
  final TextStyle? untoggledTextStyle;

  // Toggled state properties for Icon and Text
  final IconData? toggledIcon; // Made optional
  final Color? toggledColor; // Optional icon/text color for toggled state
  final String? toggledText; // Optional text for toggled state
  final TextStyle? toggledTextStyle;

  final double iconSize;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final Duration animationDuration;

  const AppToggleButton({
    Key? key,
    required this.isToggled,
    required this.onToggle,
    this.untoggledIcon, // No longer required
    this.untoggledColor,
    this.untoggledText,
    this.untoggledTextStyle,
    this.toggledIcon, // No longer required
    this.toggledColor,
    this.toggledText,
    this.toggledTextStyle,
    this.iconSize = 24.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.animationDuration = const Duration(milliseconds: 200),
  }) : super(key: key);

  @override
  State<AppToggleButton> createState() => _AppToggleButtonState();
}

class _AppToggleButtonState extends State<AppToggleButton> {
  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine the current icon (now nullable)
    final IconData? currentIcon = widget.isToggled ? widget.toggledIcon : widget.untoggledIcon;

    // Determine the icon and text color based on toggle state and theme
    // Preserving your direct color assignment
    final Color currentForegroundColor = const Color(0xFFD6AF0C);

    // Determine the background color of the AnimatedContainer (the overall button area)
    final Color currentBackgroundColor = Colors.transparent;

    // Determine the text style
    final TextStyle currentTextStyle = TextStyle(color: currentForegroundColor, fontSize: 20.0, fontWeight: FontWeight.w900);

    // Determine the current text
    final String? currentText = widget.isToggled ? widget.toggledText : widget.untoggledText;

    return SizedBox( // Wrap with SizedBox to force full width
      width: double.infinity,
      child: AnimatedContainer(
        duration: widget.animationDuration,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: currentBackgroundColor,
          borderRadius: widget.borderRadius,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute content to ends
          children: [
            // Left side: Optional Icon and optional Text
            Row(
              mainAxisSize: MainAxisSize.min, // Keep icon and text grouped
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Conditionally render Icon only if currentIcon is not null
                if (currentIcon != null)
                  Icon(
                    currentIcon,
                    color: currentForegroundColor,
                    size: widget.iconSize,
                  ),
                // Add spacing only if both icon and text are present
                if (currentIcon != null && currentText != null && currentText.isNotEmpty)
                  const SizedBox(width: 8.0),
                if (currentText != null) // Conditionally render Text
                  AnimatedSwitcher(
                    duration: widget.animationDuration, // Corrected typo here
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: Text(
                      currentText,
                      key: ValueKey<String>(currentText),
                      style: currentTextStyle,
                    ),
                  ),
              ],
            ),

            // Right side: The Toggle Switch Button itself
            Switch(
              value: widget.isToggled,
              onChanged: widget.onToggle,
              activeColor: const Color(0xFFD6AF0C),
              activeTrackColor: const Color(0xFFD6AF0C).withOpacity(0.5),
              inactiveThumbColor: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
              inactiveTrackColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            ),
          ],
        ),
      ),
    );
  }
}