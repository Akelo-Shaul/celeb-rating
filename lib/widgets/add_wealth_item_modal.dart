import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart';
import 'app_buttons.dart';
import 'app_text_fields.dart';
import 'app_dropdown.dart';

class AddWealthItemModal extends StatefulWidget {
  final void Function(Map<String, dynamic> wealthItem) onAdd;
  const AddWealthItemModal({super.key, required this.onAdd});

  @override
  State<AddWealthItemModal> createState() => _AddWealthItemModalState();
}

class _AddWealthItemModalState extends State<AddWealthItemModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  String? _selectedCategory;
  XFile? _pickedImage;

  final List<String> _categories = [
    'Car', 'House', 'Art', 'Property', 'Jewelry', 'Stocks', 'Business', 'Other'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onAdd({
      'name': _nameController.text.trim(),
      'description': _descController.text.trim(),
      'category': _selectedCategory,
      'value': _valueController.text.trim(),
    });
    Navigator.of(context).pop();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() {
        _pickedImage = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final appPrimaryColor = const Color(0xFFD6AF0C);
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
                  AppLocalizations.of(context)!.addWealthItem,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                AppDropdownFormField<String>(
                  labelText: AppLocalizations.of(context)!.category,
                  icon: Icons.category,
                  value: _selectedCategory,
                  items: _categories.map((cat) => DropdownMenuItem(
                    value: cat,
                    child: Text(AppLocalizations.of(context)!.categoryValue(cat)),
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val),
                  validator: (v) => v == null || v.isEmpty ? AppLocalizations.of(context)!.selectCategory : null,
                ),
                const SizedBox(height: 14),
                AppTextFormField(
                  controller: _nameController,
                  labelText: AppLocalizations.of(context)!.name,
                  icon: Icons.label,
                  validator: (v) => v == null || v.trim().isEmpty ? AppLocalizations.of(context)!.enterName : null,
                ),
                const SizedBox(height: 14),
                AppTextFormField(
                  controller: _descController,
                  labelText: AppLocalizations.of(context)!.description,
                  icon: Icons.description,
                  // maxLines: 2,
                  validator: (v) => v == null || v.trim().isEmpty ? AppLocalizations.of(context)!.enterDescription : null,
                ),
                const SizedBox(height: 14),
                AppTextFormField(
                  controller: _valueController,
                  labelText: AppLocalizations.of(context)!.estimatedValueOptional,
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
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
