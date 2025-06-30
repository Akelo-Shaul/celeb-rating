import 'package:flutter/material.dart';

class AppToggleButton extends StatelessWidget {
  final String labelText;
  final IconData icon;
  final bool value; // The current state of the toggle (true/false)
  final ValueChanged<bool>? onChanged; // Callback when the value changes

  const AppToggleButton({
    super.key,
    required this.labelText,
    required this.icon,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color fillColor = isDark ? const Color(0xFF23262F) : Colors.white;
    final Color borderColor = Colors.grey.shade300;
    final Color hintColor = isDark ? Colors.white70 : Colors.grey;
    final Color iconColor = isDark ? Colors.white : Colors.grey;

    return InkWell(
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        height: 50, // Consistent height with other form fields
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 0), // Adjust padding as prefixIcon adds its own
        child: Row(
          children: [
            // Prefix Icon section
            Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: borderColor),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 12), // Spacing after icon
            Expanded(
              child: Text(
                labelText,
                style: TextStyle(
                  color: hintColor,
                  fontSize: 16, // Consistent with InputDecoration's default hint text size
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12.0), // Padding for the switch
              child: Switch(
                value: value,
                onChanged: onChanged,
                activeColor: Theme.of(context).primaryColor, // Thumb color when active (primary color)
                // --- MODIFICATION START ---
                activeTrackColor: Colors.amber, // Track color when active (app yellow)
                // --- MODIFICATION END ---
                inactiveThumbColor: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                inactiveTrackColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              ),
            ),
          ],
        ),
      ),
    );
  }
}