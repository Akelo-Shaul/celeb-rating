import 'dart:io';

import 'package:celebrating/widgets/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../l10n/app_localizations.dart';
import 'app_buttons.dart';
import 'app_text_fields.dart';

class AddFamilyMemberModal extends StatefulWidget {
  final void Function(Map<String, dynamic> member) onAdd;

  const AddFamilyMemberModal({super.key, required this.onAdd});

  @override
  State<AddFamilyMemberModal> createState() => _AddFamilyMemberModalState();
}

class _AddFamilyMemberModalState extends State<AddFamilyMemberModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final Map<String, TextEditingController> _socialControllers = {
    'Instagram': TextEditingController(),
    'Twitter': TextEditingController(),
    'Facebook': TextEditingController(),
    'TikTok': TextEditingController(),
    'Snapchat': TextEditingController(),
  };
  XFile? _pickedImage;
  bool _isLoading = false;

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

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          top: 16.0,
          left: 16.0,
          right: 16.0,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppLocalizations.of(context)!.addFamilyMember,
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
                // Photo picker
                Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.grey[200],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _pickedImage != null
                      ? Image.file(
                    File(_pickedImage!.path),
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                  )
                      : const Center(
                    child: Icon(Icons.camera_alt, size: 48, color: Colors.grey),
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
                AppTextFormField(
                  controller: _fullNameController,
                  labelText: AppLocalizations.of(context)!.fullName,
                  icon: Icons.person,
                  validator: (v) => v == null || v.trim().isEmpty ? AppLocalizations.of(context)!.enterFullName : null,
                ),
                const SizedBox(height: 14),
                AppTextFormField(
                  controller: _ageController,
                  labelText: AppLocalizations.of(context)!.age,
                  icon: Icons.cake,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return AppLocalizations.of(context)!.enterAge;
                    final n = int.tryParse(v);
                    if (n == null || n < 0) return AppLocalizations.of(context)!.enterValidAge;
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                ..._socialControllers.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppTextFormField(
                    controller: entry.value,
                    labelText: AppLocalizations.of(context)!.socialUsername(entry.key),
                    icon: _getSocialIcon(entry.key),
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
