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
  final Map<String, dynamic>? initialData;
  final bool isEdit;
  const AddEducationModal({
    super.key,
    required this.onAdd,
    this.initialData,
    this.isEdit = false,
  });

  @override
  State<AddEducationModal> createState() => _AddEducationModalState();
}

class _AddEducationModalState extends State<AddEducationModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _institutionController = TextEditingController();
  List<Map<String, String>> _degrees = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final data = widget.initialData!;
      if (data['institution'] != null) _institutionController.text = data['institution'];
      if (data['qualifications'] != null && data['qualifications'] is List) {
        _degrees = List<Map<String, String>>.from(data['qualifications']);
      }
    }
    if (_degrees.isEmpty) {
      _degrees.add({'title': '', 'year': ''});
    }
  }

  // Removed unused variables:
  // TextEditingController _nameController
  // TextEditingController _descController
  // String? _selectedCategory
  // XFile? _pickedImage

  @override
  void dispose() {
    _institutionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onAdd({
      'institution': _institutionController.text.trim(),
      'qualifications': _degrees.map((deg) => {
        'title': deg['title'] ?? '',
        'year': deg['year'] ?? '',
      }).toList(),
    });
    Navigator.of(context).pop();
  }

  // Removed _pickImage method as it's not used in the UI
  // Future<void> _pickImage(ImageSource source) async { ... }

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
            child: Form(
              key: _formKey,
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
                    widget.isEdit ? (AppLocalizations.of(context)!.editEducation ?? 'Edit Education') : AppLocalizations.of(context)!.addEducation,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _institutionController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.certifyingInstitution,
                      prefixIcon: Icon(Icons.account_balance),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? AppLocalizations.of(context)!.enterName : null,
                  ),
                  const SizedBox(height: 14),
                  ..._degrees.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final deg = entry.value;
                    final isInitialAdd = !widget.isEdit && _degrees.length == 1 && deg['title']!.isEmpty && deg['year']!.isEmpty;
                    final titleController = TextEditingController(text: deg['title']);
                    final yearController = TextEditingController(text: deg['year']);
                    return StatefulBuilder(
                      builder: (context, setLocalState) {
                        return Column(
                          children: [
                            TextFormField(
                              controller: titleController,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.qualificationLabel,
                                prefixIcon: Icon(Icons.school),
                              ),
                              onChanged: (val) {
                                setLocalState(() { titleController.text = val; });
                                setState(() { _degrees[idx]['title'] = val; });
                              },
                              validator: (v) => v == null || v.trim().isEmpty ? AppLocalizations.of(context)!.enterDescription : null,
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: yearController,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.yearOfCompletion,
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              readOnly: true,
                              onTap: () async {
                                final picked = await CustomDatePicker.show(context);
                                if (picked != null) {
                                  setLocalState(() { yearController.text = picked.year.toString(); });
                                  setState(() { _degrees[idx]['year'] = picked.year.toString(); });
                                }
                              },
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return AppLocalizations.of(context)!.enterYear;
                                }
                                return null;
                              },
                            ),
                            if (!isInitialAdd)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove_circle, color: Colors.redAccent),
                                    tooltip: 'Remove degree',
                                    onPressed: () {
                                      setState(() {
                                        _degrees.removeAt(idx);
                                      });
                                      if (_degrees.isEmpty) {
                                        Navigator.of(context).pop();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            const SizedBox(height: 14),
                          ],
                        );
                      },
                    );
                  }).toList(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(Icons.add),
                        label: Text(AppLocalizations.of(context)!.addQualification ?? 'Add Degree'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appPrimaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        ),
                        onPressed: () {
                          setState(() {
                            _degrees.add({'title': '', 'year': ''});
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(widget.isEdit ? Icons.edit : Icons.check),
                      label: Text(widget.isEdit ? (AppLocalizations.of(context)!.edit ?? 'Edit') : AppLocalizations.of(context)!.add),
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
      ),
    );
  }
}