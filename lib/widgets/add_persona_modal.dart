import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart';
import 'app_buttons.dart';
import 'app_date_picker.dart';
import 'app_text_fields.dart';
import 'app_dropdown.dart';

class AddPersonaModal extends StatefulWidget {
  final void Function(Map<String, dynamic> personaItem) onAdd;
  final String sectionTitle;
  const AddPersonaModal({super.key, required this.onAdd, required this.sectionTitle});

  @override
  State<AddPersonaModal> createState() => _AddPersonaModalState();
}

class _AddPersonaModalState extends State<AddPersonaModal> {
  final _formKey = GlobalKey<FormState>();
  // Controllers for all possible fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _valueController = TextEditingController(); // unused now
  final TextEditingController _bodyPartController = TextEditingController(); // tattoos
  final TextEditingController _locationController = TextEditingController(); // favourite places
  final TextEditingController _reasonController = TextEditingController(); // favourite places
  final TextEditingController _startYearController = TextEditingController(); // talents, hobbies
  final TextEditingController _inspirationController = TextEditingController(); // fashion style
  XFile? _pickedImage;
  DateTime? _selectStartDate;

  final List<String> _personaTypes = [
    'Tattoos', 'Favourite Places', 'Talents', 'Hobbies', 'Fashion Style'
  ];
  String? _selectedPersonaType;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _valueController.dispose();
    _bodyPartController.dispose();
    _locationController.dispose();
    _reasonController.dispose();
    _startYearController.dispose();
    _inspirationController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final Map<String, dynamic> data = {'type': _selectedPersonaType};
    switch (_selectedPersonaType) {
      case 'Tattoos':
        data.addAll({
          'name': _nameController.text.trim(),
          'bodyPart': _bodyPartController.text.trim(),
          'description': _descController.text.trim(),
        });
        break;
      case 'Favourite Places':
        data.addAll({
          'location': _locationController.text.trim(),
          'description': _descController.text.trim(),
          'reason': _reasonController.text.trim(),
        });
        break;
      case 'Talents':
        data.addAll({
          'name': _nameController.text.trim(),
          'description': _descController.text.trim(),
          'startYear': _startYearController.text.trim(),
        });
        break;
      case 'Hobbies':
        data.addAll({
          'name': _nameController.text.trim(),
          'description': _descController.text.trim(),
          'startYear': _startYearController.text.trim(),
        });
        break;
      case 'Fashion Style':
        data.addAll({
      'name': _nameController.text.trim(),
      'description': _descController.text.trim(),
          'inspiration': _inspirationController.text.trim(),
    });
        break;
    }
    widget.onAdd(data);
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

  List<Widget> _buildFieldsForType(String? type) {
    final loc = AppLocalizations.of(context)!;
    switch (type) {
      case 'Tattoos':
        return [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: loc.name,
              prefixIcon: Icon(Icons.label),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? loc.enterName : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _bodyPartController,
            decoration: InputDecoration(
              labelText: 'Body Part',
              prefixIcon: Icon(Icons.accessibility_new),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Enter body part' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _descController,
            decoration: InputDecoration(
              labelText: loc.description,
              prefixIcon: Icon(Icons.description),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? loc.enterDescription : null,
          ),
        ];
      case 'Favourite Places':
        return [
          TextFormField(
            controller: _locationController,
            decoration: InputDecoration(
              labelText: 'Location',
              prefixIcon: Icon(Icons.location_on),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Enter location' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _descController,
            decoration: InputDecoration(
              labelText: loc.description,
              prefixIcon: Icon(Icons.description),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? loc.enterDescription : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _reasonController,
            decoration: InputDecoration(
              labelText: 'Reason',
              prefixIcon: Icon(Icons.question_answer),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Enter reason' : null,
          ),
        ];
      case 'Talents':
        return [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: loc.name,
              prefixIcon: Icon(Icons.label),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? loc.enterName : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _descController,
            decoration: InputDecoration(
              labelText: loc.description,
              prefixIcon: Icon(Icons.description),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? loc.enterDescription : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _startYearController,
            decoration: InputDecoration(
              labelText: 'Start Year',
              prefixIcon: Icon(Icons.calendar_today),
            ),
            readOnly: true,
            onTap: () async {
              final picked = await CustomDatePicker.show(context);
              if (picked != null) {
                setState(() {
                  _selectStartDate = picked;
                  _startYearController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
                });
              }
            },
            validator: (v) {
              if (v == null || v.trim().isEmpty) return AppLocalizations.of(context)!.enterAge;
              return null;
            },
          ),
        ];
      case 'Hobbies':
        return [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: loc.name,
              prefixIcon: Icon(Icons.label),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? loc.enterName : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _descController,
            decoration: InputDecoration(
              labelText: loc.description,
              prefixIcon: Icon(Icons.description),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? loc.enterDescription : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _startYearController,
            decoration: InputDecoration(
              labelText: 'Start Year',
              prefixIcon: Icon(Icons.calendar_today),
            ),
            readOnly: true,
            onTap: () async {
              final picked = await CustomDatePicker.show(context);
              if (picked != null) {
                setState(() {
                  _selectStartDate = picked;
                  _startYearController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
                });
              }
            },
          ),
        ];
      case 'Fashion Style':
        return [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: loc.name,
              prefixIcon: Icon(Icons.label),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? loc.enterName : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _descController,
            decoration: InputDecoration(
              labelText: loc.description,
              prefixIcon: Icon(Icons.description),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? loc.enterDescription : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _inspirationController,
            decoration: InputDecoration(
              labelText: 'Inspiration',
              prefixIcon: Icon(Icons.lightbulb_outline),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Enter inspiration' : null,
          ),
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final appPrimaryColor = const Color(0xFFD6AF0C);
    final bool hasSectionTitle = (widget.sectionTitle.isNotEmpty);
    if (hasSectionTitle && _selectedPersonaType != widget.sectionTitle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_selectedPersonaType != widget.sectionTitle) {
          setState(() {
            _selectedPersonaType = widget.sectionTitle;
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
                    widget.sectionTitle,
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
                  // Persona type dropdown
                  if (!hasSectionTitle)
                    DropdownButtonFormField<String>(
                      value: _selectedPersonaType,
                      decoration: InputDecoration(
                        labelText: 'Type',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _personaTypes.map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      )).toList(),
                      onChanged: (val) => setState(() => _selectedPersonaType = val),
                      validator: (v) => v == null || v.isEmpty ? 'Select type' : null,
                    ),
                  if (hasSectionTitle)
                    DropdownButtonFormField<String>(
                      value: _selectedPersonaType,
                      decoration: InputDecoration(
                        labelText: 'Type',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: [DropdownMenuItem(
                        value: widget.sectionTitle,
                        child: Text(widget.sectionTitle),
                      )],
                      onChanged: null,
                      validator: (v) => v == null || v.isEmpty ? 'Select type' : null,
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
                  const SizedBox(height: 14),
                  ..._buildFieldsForType(_selectedPersonaType),
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
      ),
    );
  }
}
