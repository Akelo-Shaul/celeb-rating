import 'package:flutter/material.dart';

class AppSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onFilterPressed;
  final bool showFilterButton;
  final bool showSearchButton;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;
  final Color? hintColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? contentPadding;

  const AppSearchBar({
    Key? key,
    this.controller,
    this.hintText = 'Search...', // Default hint text
    this.onChanged,
    this.onSearchPressed,
    this.onFilterPressed,
    this.showFilterButton = true, // Default to showing filter button
    this.showSearchButton = true, // Default to showing search button
    this.backgroundColor,
    this.iconColor,
    this.textColor,
    this.hintColor,
    this.borderRadius,
    this.padding,
    this.contentPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine colors based on theme if not provided
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color effectiveBackgroundColor = backgroundColor ?? (isDark ? Colors.grey.shade900 : Colors.grey.shade100);
    final Color effectiveIconColor = iconColor ?? (isDark ? Colors.white : Colors.black87);
    final Color effectiveTextColor = textColor ?? (isDark ? Colors.white : Colors.black87);
    final Color effectiveHintColor = hintColor ?? (isDark ? Colors.grey.shade400 : Colors.grey.shade600);
    final BoxShadow boxShadow = isDark
        ? const BoxShadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 2))
        : const BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2));

    return Container(
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: borderRadius ?? BorderRadius.circular(30.0),
        boxShadow: [boxShadow],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(color: effectiveTextColor),
        cursorColor: effectiveIconColor,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: effectiveHintColor),
          prefixIcon: showSearchButton
              ? IconButton(
                  icon: Icon(Icons.search, color: effectiveIconColor),
                  onPressed: onSearchPressed,
                )
              : null,
          suffixIcon: showFilterButton
              ? IconButton(
                  icon: Icon(Icons.filter_list, color: effectiveIconColor),
                  onPressed: onFilterPressed,
                )
              : null,
          border: InputBorder.none,
          contentPadding: contentPadding ?? const EdgeInsets.symmetric(vertical: 14.0),
          isDense: true,
        ),
      ),
    );
  }
}