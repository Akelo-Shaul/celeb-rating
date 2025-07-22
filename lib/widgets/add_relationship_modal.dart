import 'dart:io';

import 'package:celebrating/widgets/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../l10n/app_localizations.dart';
import 'app_buttons.dart';
import 'app_text_fields.dart';
import '../utils/route.dart';
import 'app_date_picker.dart';

class AddRelationshipModal extends StatefulWidget {
  final void Function(Map<String, dynamic> member) onAdd;
  final String? sectionTitle;
  const AddRelationshipModal({super.key, required this.onAdd, this.sectionTitle});

  @override
  State<AddRelationshipModal> createState() => _AddFamilyMemberModalState();
}

class _AddFamilyMemberModalState extends State<AddRelationshipModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  DateTime? _selectedBirthDate;
  final Map<String, TextEditingController> _socialControllers = {
    'Instagram': TextEditingController(),
    'Twitter': TextEditingController(),
    'Facebook': TextEditingController(),
    'TikTok': TextEditingController(),
    'Snapchat': TextEditingController(),
  };
  XFile? _pickedImage;
  bool _isLoading = false;
  final List<String> _relationshipTypes = [
    'Mother', 'Father', 'Spouse', 'Grandparent', 'Sibling', 'Child', 'Friend', 'Pet', 'Aunt', 'Uncle', 'Cousin', 'Other'
  ];
  String? _selectedRelationship;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() {
        _pickedImage = picked;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onAdd({
      'fullName': _fullNameController.text.trim(),
      'age': _ageController.text.trim(),
      'photo': _pickedImage,
      'socials': _socialControllers.map((k, v) => MapEntry(k, v.text.trim())),
    });
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _ageController.dispose();
    for (final c in _socialControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  IconData _getSocialIcon(String key) {
    switch (key.toLowerCase()) {
      case 'instagram':
        return Icons.camera_alt;
      case 'twitter':
        return Icons.alternate_email;
      case 'facebook':
        return Icons.facebook;
      case 'tiktok':
        return Icons.music_note;
      case 'snapchat':
        return Icons.chat_bubble_outline;
      default:
        return Icons.account_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final appPrimaryColor = Color(0xFFD6AF0C);
    final bool hasSectionTitle = (widget.sectionTitle != null && widget.sectionTitle!.isNotEmpty);
    if (hasSectionTitle && _selectedRelationship != widget.sectionTitle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_selectedRelationship != widget.sectionTitle) {
          setState(() {
            _selectedRelationship = widget.sectionTitle;
          });
        }
      });
    }
    return Padding(
      padding: const EdgeInsets.only(top: 40), // leave space for the close button
      child: SingleChildScrollView(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            padding: EdgeInsets.only(
              top: 24, // Ensures content is below the system UI
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
                  widget.sectionTitle ?? 'Add Relationship',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: defaultTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10,),
                Container(
                  height: 4,
                  width: 40,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: secondaryTextColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Relationship type dropdown
                if (!hasSectionTitle)
                  DropdownButtonFormField<String>(
                    value: _selectedRelationship,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.relationshipType,
                      prefixIcon: Icon(Icons.group),
                    ),
                    items: _relationshipTypes.map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedRelationship = val),
                    validator: (v) => v == null || v.isEmpty ? AppLocalizations.of(context)!.selectCategory : null,
                  ),
                if (hasSectionTitle)
                  DropdownButtonFormField<String>(
                    value: _selectedRelationship,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.relationshipType,
                      prefixIcon: Icon(Icons.group),
                    ),
                    items: [DropdownMenuItem(
                      value: widget.sectionTitle,
                      child: Text(widget.sectionTitle!),
                    )],
                    onChanged: null,
                    validator: (v) => v == null || v.isEmpty ? AppLocalizations.of(context)!.selectCategory : null,
                  ),
                const SizedBox(height: 14),
                // Photo picker
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.grey[200],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _pickedImage != null
                        ? Image.file(
                            File(_pickedImage!.path),
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          )
                        : const Center(
                            child: Icon(Icons.camera_alt, size: 36, color: Colors.grey),
                          ),
                  ),
                ),
                const SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: AppButton(
                        icon: Icons.photo_camera,
                        text: AppLocalizations.of(context)!.openCamera,
                        onPressed: () => _pickImage(ImageSource.camera),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: AppButton(
                        icon: Icons.photo_library,
                        text: AppLocalizations.of(context)!.openGallery,
                        onPressed: () => _pickImage(ImageSource.gallery),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.fullName,
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? AppLocalizations.of(context)!.enterFullName : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _ageController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.age,
                    prefixIcon: Icon(Icons.cake),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final picked = await CustomDatePicker.show(context);
                    if (picked != null) {
                      setState(() {
                        _selectedBirthDate = picked;
                        _ageController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
                      });
                    }
                  },
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return AppLocalizations.of(context)!.enterAge;
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                ..._socialControllers.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    controller: entry.value,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.socialUsername(entry.key),
                      prefixIcon: Icon(_getSocialIcon(entry.key)),
                    ),
                  ),
                )),
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
                    onPressed: _isLoading ? null : _submit,
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
