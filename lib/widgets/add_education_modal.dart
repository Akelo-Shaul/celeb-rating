import 'dart:io'; // Still needed for File if _pickedImage was used, but will be removed for this modal

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Still needed for ImagePicker if _pickedImage was used
import '../l10n/app_localizations.dart';
import 'app_buttons.dart'; // Keeping these imports as they might be used elsewhere, though not directly in the provided snippet's UI for this modal.
import 'app_text_fields.dart'; // Keeping these imports
import 'app_dropdown.dart'; // Keeping these imports
import 'app_date_picker.dart';

class AddEducationModal extends StatefulWidget {
  final void Function(Map<String, dynamic> educationItem) onAdd;
  const AddEducationModal({super.key, required this.onAdd});

  @override
  State<AddEducationModal> createState() => _AddEducationModalState();
}

class _AddEducationModalState extends State<AddEducationModal> {
  final _formKey = GlobalKey<FormState>();

  // Declaring missing controllers
  final TextEditingController _institutionController = TextEditingController();
  final TextEditingController _qualificationController = TextEditingController();
  final TextEditingController _valueController = TextEditingController(); // This was already declared but now its purpose is clearer as year of completion.

  // Removed unused variables:
  // TextEditingController _nameController
  // TextEditingController _descController
  // String? _selectedCategory
  // XFile? _pickedImage

  @override
  void dispose() {
    _institutionController.dispose(); // Dispose the new controller
    _qualificationController.dispose();    // Dispose the new controller
    _valueController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onAdd({
      'institution': _institutionController.text.trim(), // Renamed 'name' to 'university'
      'qualification': _qualificationController.text.trim(),       // Renamed 'description' to 'degree'
      'yearOfCompletion': _valueController.text.trim(), // Renamed 'value' to 'yearOfCompletion'
      // Removed 'category' as it's not used in the form
    });
    Navigator.of(context).pop();
  }

  // Removed _pickImage method as it's not used in the UI
  // Future<void> _pickImage(ImageSource source) async { ... }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // secondaryTextColor and appPrimaryColor are defined but not used with `AppLocalizations`,
    // keeping them if they are intended for future styling or dynamic color application.
    final secondaryTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final appPrimaryColor = const Color(0xFFD6AF0C);

    return Padding(
      padding: const EdgeInsets.only(top: 40), // leave space for the close button
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
                  AppLocalizations.of(context)!.addEducation,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _institutionController, // Declared and used
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.certifyingInstitution,
                    prefixIcon: Icon(Icons.account_balance),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? AppLocalizations.of(context)!.enterName : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _qualificationController, // Declared and used
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.qualificationLabel,
                    prefixIcon: Icon(Icons.school),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? AppLocalizations.of(context)!.enterDescription : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _valueController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.yearOfCompletion,
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final picked = await CustomDatePicker.show(context);
                    if (picked != null) {
                      setState(() {
                        _valueController.text = picked.year.toString();
                      });
                    }
                  },
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return AppLocalizations.of(context)!.enterYear;
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