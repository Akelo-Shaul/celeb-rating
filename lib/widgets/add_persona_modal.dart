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
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _socialPlatformController = TextEditingController();
  final TextEditingController _socialLinkController = TextEditingController();
  final TextEditingController _followerCountController = TextEditingController();
  final TextEditingController _publicImageTitleController = TextEditingController();
  final TextEditingController _publicImageDescController = TextEditingController();
  // Removed _controversyTitleController and _controversyDescController
  final TextEditingController _fashionStyleTitleController = TextEditingController();
  final TextEditingController _fashionStyleDescController = TextEditingController();
  final TextEditingController _redCarpetTitleController = TextEditingController(); // New
  final TextEditingController _redCarpetDescController = TextEditingController(); // New
  final TextEditingController _quoteController = TextEditingController();
  final TextEditingController _quoteContextController = TextEditingController();


  XFile? _pickedImage;
  DateTime? _selectStartDate;

  // Updated persona types for Public Persona tab
  final List<String> _personaTypes = [
    'Social Media Presence',
    'Public Image / Reputation',
    'Fashion Style', // Separated
    'Red Carpet Moments', // Separated
    'Quotes or Public Statements'
  ];
  String? _selectedPersonaType;

  @override
  void initState() {
    super.initState();
    // Set initial selected persona type based on sectionTitle
    _selectedPersonaType = widget.sectionTitle;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _valueController.dispose();
    _socialPlatformController.dispose();
    _socialLinkController.dispose();
    _followerCountController.dispose();
    _publicImageTitleController.dispose();
    _publicImageDescController.dispose();
    // Removed dispose for controversy controllers
    _fashionStyleTitleController.dispose();
    _fashionStyleDescController.dispose();
    _redCarpetTitleController.dispose(); // New dispose
    _redCarpetDescController.dispose(); // New dispose
    _quoteController.dispose();
    _quoteContextController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final Map<String, dynamic> data = {'type': _selectedPersonaType};

    switch (_selectedPersonaType) {
      case 'Social Media Presence':
        data.addAll({
          'platform': _socialPlatformController.text.trim(),
          'link': _socialLinkController.text.trim(),
          'followers': _followerCountController.text.trim(),
        });
        break;
      case 'Public Image / Reputation':
        data.addAll({
          'title': _publicImageTitleController.text.trim(),
          'description': _publicImageDescController.text.trim(),
        });
        break;
    // Removed 'Controversies or Scandals' case
      case 'Fashion Style': // Separated
        data.addAll({
          'title': _fashionStyleTitleController.text.trim(),
          'description': _fashionStyleDescController.text.trim(),
        });
        break;
      case 'Red Carpet Moments': // Separated
        data.addAll({
          'title': _redCarpetTitleController.text.trim(),
          'description': _redCarpetDescController.text.trim(),
        });
        break;
      case 'Quotes or Public Statements':
        data.addAll({
          'quote': _quoteController.text.trim(),
          'context': _quoteContextController.text.trim(),
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
      case 'Social Media Presence':
        return [
          TextFormField(
            controller: _socialPlatformController,
            decoration: InputDecoration(
              labelText: 'Platform',
              prefixIcon: Icon(Icons.public),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Enter platform' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _socialLinkController,
            decoration: InputDecoration(
              labelText: 'Link',
              prefixIcon: Icon(Icons.link),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Enter link' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _followerCountController,
            decoration: InputDecoration(
              labelText: 'Follower Count',
              prefixIcon: Icon(Icons.people),
            ),
            keyboardType: TextInputType.number,
            validator: (v) => v == null || v.trim().isEmpty ? 'Enter follower count' : null,
          ),
        ];
      case 'Public Image / Reputation':
        return [
          TextFormField(
            controller: _publicImageTitleController,
            decoration: InputDecoration(
              labelText: 'Title',
              prefixIcon: Icon(Icons.title),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Enter title' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _publicImageDescController,
            decoration: InputDecoration(
              labelText: 'Description',
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 3,
            validator: (v) => v == null || v.trim().isEmpty ? 'Enter description' : null,
          ),
        ];
    // Removed 'Controversies or Scandals' case
      case 'Fashion Style': // Separated
        return [
          TextFormField(
            controller: _fashionStyleTitleController,
            decoration: InputDecoration(
              labelText: 'Style Name/Characteristic',
              prefixIcon: Icon(Icons.checkroom),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Enter style name' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _fashionStyleDescController,
            decoration: InputDecoration(
              labelText: 'Description',
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 3,
            validator: (v) => v == null || v.trim().isEmpty ? 'Enter description' : null,
          ),
        ];
      case 'Red Carpet Moments': // Separated
        return [
          TextFormField(
            controller: _redCarpetTitleController,
            decoration: InputDecoration(
              labelText: 'Event/Moment Name',
              prefixIcon: Icon(Icons.movie_filter),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Enter event name' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _redCarpetDescController,
            decoration: InputDecoration(
              labelText: 'Description (Outfit, Designer, Impact)',
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 3,
            validator: (v) => v == null || v.trim().isEmpty ? 'Enter description' : null,
          ),
        ];
      case 'Quotes or Public Statements':
        return [
          TextFormField(
            controller: _quoteController,
            decoration: InputDecoration(
              labelText: 'Quote',
              prefixIcon: Icon(Icons.format_quote),
            ),
            maxLines: 3,
            validator: (v) => v == null || v.trim().isEmpty ? 'Enter quote' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _quoteContextController,
            decoration: InputDecoration(
              labelText: 'Context/Source',
              prefixIcon: Icon(Icons.info_outline),
            ),
            maxLines: 2,
            validator: (v) => v == null || v.trim().isEmpty ? 'Enter context' : null,
          ),
        ];
      default:
        return [
          Center(
            child: Text(loc.selectTypePrompt),
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appPrimaryColor = Theme.of(context).primaryColor;
    final localizations = AppLocalizations.of(context)!;

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.pop(context);
        }
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: controller,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.sectionTitle, // Use sectionTitle passed from parent
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).appBarTheme.titleTextStyle?.color,
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppDropdown<String>(
                      value: _selectedPersonaType,
                      items: _personaTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      labelText: localizations.selectPersonaType,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedPersonaType = newValue;
                        });
                      },
                      validator: (v) => v == null ? localizations.selectTypeValidation : null,
                    ),
                    const SizedBox(height: 20),
                    if (_selectedPersonaType != null) ...[
                      ..._buildFieldsForType(_selectedPersonaType),
                      const SizedBox(height: 14),
                      _pickedImage != null
                          ? Image.file(
                        File(_pickedImage!.path),
                        height: 150,
                        fit: BoxFit.cover,
                      )
                          : Container(),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Flexible(
                            child: AppButton(
                              icon: Icons.camera_alt,
                              text: localizations.takePhoto,
                              onPressed: () => _pickImage(ImageSource.camera),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: AppButton(
                              icon: Icons.photo_library,
                              text: localizations.openGallery,
                              onPressed: () => _pickImage(ImageSource.gallery),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check),
                          label: Text(localizations.add),
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}