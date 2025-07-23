import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart';
import 'app_buttons.dart';
import 'app_text_fields.dart';
import 'app_dropdown.dart';

class AddCareerHighlightsModal extends StatefulWidget {
  final void Function(Map<String, dynamic> careerHighlightItem) onAdd;
  const AddCareerHighlightsModal({super.key, required this.onAdd});

  @override
  State<AddCareerHighlightsModal> createState() => _AddCareerHighlightsModalState();
}

class _AddCareerHighlightsModalState extends State<AddCareerHighlightsModal> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _awardsController = TextEditingController();
  final TextEditingController _collaboratorController = TextEditingController();
  final TextEditingController _yearController = TextEditingController(); // Added for year of achievement

  @override
  void dispose() {
    _titleController.dispose();
    _roleController.dispose();
    _awardsController.dispose();
    _collaboratorController.dispose(); // Dispose the new controller
    _yearController.dispose(); // Dispose the new controller
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onAdd({
      'title': _titleController.text.trim(),
      'role': _roleController.text.trim(),
      'awards': _awardsController.text.trim(), // Changed key from 'awards won' to 'awards' for consistency
      'collaborators': _collaboratorController.text.trim(),
      'year': _yearController.text.trim(), // Added year
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final appPrimaryColor = const Color(0xFFD6AF0C);

    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: SingleChildScrollView(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            padding: EdgeInsets.only(
              top: 24,
              left: 16.0,
              right: 16.0,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.grey[700], size: 28),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Close',
                    ),
                  ],
                ),
                Text(
                  AppLocalizations.of(context)!.addCareerHighlight, // Updated string
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.highlightTitle, // Updated label
                    prefixIcon: Icon(Icons.military_tech), // Relevant icon
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? AppLocalizations.of(context)!.enterHighlightTitle : null, // Updated validator string
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _roleController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.yourRole, // Updated label
                    prefixIcon: Icon(Icons.work), // Relevant icon
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? AppLocalizations.of(context)!.enterYourRole : null, // Updated validator string
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _awardsController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.awardsRecognition, // Updated label
                    prefixIcon: Icon(Icons.emoji_events), // Relevant icon
                  ),
                  // No specific validator for comma-separated string, can be optional
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _collaboratorController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.collaborators, // Updated label
                    prefixIcon: Icon(Icons.people), // Relevant icon
                  ),
                  // No specific validator for comma-separated string, can be optional
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _yearController, // New field for year
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.yearOfAchievement, // Updated label
                    prefixIcon: Icon(Icons.calendar_today), // Relevant icon
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return AppLocalizations.of(context)!.enterYear;
                    }
                    if (int.tryParse(v.trim()) == null) {
                      return AppLocalizations.of(context)!.enterValidYear;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: Text(AppLocalizations.of(context)!.add),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appPrimaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _submit,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}