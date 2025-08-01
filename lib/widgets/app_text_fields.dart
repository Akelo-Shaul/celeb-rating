import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'app_date_picker.dart';

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


class AppDatePicker extends StatefulWidget {
  final String labelText;
  final IconData icon; // Added icon parameter
  final void Function(DateTime?) onDateSelected;
  final String? Function(String?)? validator;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const AppDatePicker({
    super.key,
    required this.labelText,
    this.icon = Icons.calendar_today, // Default icon
    required this.onDateSelected,
    this.validator,
    this.initialDate,
    this.firstDate,
    this.lastDate,
  });

  @override
  State<AppDatePicker> createState() => _AppDatePickerState();
}

class _AppDatePickerState extends State<AppDatePicker> {
  final TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    if (_selectedDate != null) {
      _dateController.text = DateFormat.yMMMd().format(_selectedDate!);
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await CustomDatePicker.show(context);
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat.yMMMd().format(_selectedDate!);
      });
      widget.onDateSelected(_selectedDate);
      // After selecting, trigger validation
      Future.delayed(Duration(milliseconds: 50), () {
        final form = Form.of(context);
        if (form != null) form.validate();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: TextFormField(
          controller: _dateController,
          readOnly: true, // Make it read-only
          validator: (_) => widget.validator?.call(_selectedDate?.toIso8601String()),
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: widget.labelText,
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
              child: Icon(widget.icon, color: isDark ? Colors.white : Colors.grey),
            ),
          ),
        ),
      ),
    );
  }
}