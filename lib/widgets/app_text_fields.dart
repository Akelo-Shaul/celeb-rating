import 'package:flutter/material.dart';

class AppTextFormField extends StatelessWidget {
  final String labelText;
  final IconData icon;
  final bool isPassword;
  final void Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final TextInputType? keyboardType;

  const AppTextFormField({
    super.key,
    required this.labelText,
    required this.icon,
    this.isPassword = false,
    this.onSaved,
    this.validator,
    this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      obscureText: isPassword,
      controller: controller,
      onSaved: onSaved,
      validator: validator ??
              (v) => (v == null || v.isEmpty) ? '$labelText is required' : null,
      keyboardType: keyboardType,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
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