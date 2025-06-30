import 'package:flutter/material.dart';

class AppDropdownFormField<T> extends StatelessWidget {
  final String labelText;
  final IconData icon;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final void Function(T?)? onSaved;
  final String? Function(T?)? validator;

  const AppDropdownFormField({
    super.key,
    required this.labelText,
    required this.icon,
    this.value,
    required this.items,
    this.onChanged,
    this.onSaved,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DropdownButtonFormField<T>(
      isExpanded: true,
      isDense: true,
      value: value,
      items: items.map((DropdownMenuItem<T> item) {
        if (item.child is Text) {
          final Text textChild = item.child as Text;
          return DropdownMenuItem<T>(
            value: item.value,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                textChild.data ?? '',
                style: textChild.style ?? TextStyle(color: isDark ? Colors.white : Colors.black),
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ),
          );
        }
        return item;
      }).toList(),
      onChanged: onChanged,
      onSaved: onSaved,
      validator: validator ?? (v) => (v == null) ? '$labelText is required' : null,
      decoration: InputDecoration(
        hintText: labelText,
        hintStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        filled: true,
        fillColor: isDark ? const Color(0xFF23262F) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        prefixIcon: Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(icon, color: isDark ? Colors.white : Colors.grey),
        ),
      ),
    );
  }
}



class AppDropdown<T> extends StatelessWidget {
  final String labelText; // Used as hint or current selected label
  final IconData? icon; // Optional leading icon
  final T? value; // The currently selected value
  final List<DropdownMenuItem<T>> items; // The list of dropdown items
  final void Function(T?)? onChanged; // Callback when an item is selected
  final String? Function(T?)? validator; // Optional validator for form fields
  final void Function(T?)? onSaved; // Optional onSaved for form fields
  final bool isFormField; // To conditionally apply InputDecoration for form fields
  final TextStyle? labelTextStyle; // Custom style for the labelText

  const AppDropdown({
    super.key,
    required this.labelText,
    this.icon,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.onSaved,
    this.isFormField = true, // Default to true for form field behavior
    this.labelTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Make dropdown background transparent to always blend with appbar/scaffold
    final Color fillColor = Colors.transparent;
    final Color borderColor = Colors.grey.shade300;
    final Color hintColor = isDark ? Colors.white70 : Colors.grey;
    final Color iconColor = isDark ? Colors.white : Colors.grey;

    // Base InputDecoration for consistent styling
    final InputDecoration baseDecoration = InputDecoration(
      hintText: labelText,
      hintStyle: labelTextStyle ?? TextStyle(color: hintColor),
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none, // No visible border
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none, // No visible border
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none, // No visible border
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2), // Error state
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2), // Error state on focus
      ),
      prefixIcon: icon != null
          ? Container(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: borderColor),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Icon(icon, color: iconColor),
      )
          : null, // Only show prefixIcon if icon is provided
    );

    // Apply specific padding if there's no icon, so hintText aligns correctly
    final InputDecoration finalDecoration = baseDecoration.copyWith(
      contentPadding: icon == null
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 14) // Adjust padding if no icon
          : const EdgeInsets.symmetric(vertical: 14),
    );


    return DropdownButtonFormField<T>(
      isExpanded: true,
      // isDense: true, // isDense can sometimes make text smaller, let's keep it off by default
      value: value,
      items: items.map((DropdownMenuItem<T> item) {
        // This part ensures text inside dropdown items fits and wraps properly
        if (item.child is Text) {
          final Text textChild = item.child as Text;
          return DropdownMenuItem<T>(
            value: item.value,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                textChild.data ?? '',
                style: textChild.style ?? TextStyle(color: isDark ? Colors.white : Colors.black),
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ),
          );
        }
        return item;
      }).toList(),
      onChanged: onChanged,
      // Conditional validator and onSaved for form fields
      validator: isFormField
          ? (validator ?? (v) => (v == null) ? '$labelText is required' : null)
          : null,
      onSaved: isFormField ? onSaved : null,
      decoration: finalDecoration,
      // Custom dropdown icon for the suffix (the arrow)
      // This allows you to override the default arrow if needed,
      // though the default matches your style reasonably well.
      // We can make it null for the FEED example where the text 'FEED' acts as the label.
      // But the image shows an arrow, so let's keep it.
      // dropdownColor: isDark ? const Color(0xFF23262F) : Colors.white, // Optional: set dropdown menu background color
    );
  }
}