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
  final String sectionType;
  final Map<String, dynamic>? initialData;
  final bool isEdit;
  const AddPersonaModal({
    super.key,
    required this.onAdd,
    required this.sectionType,
    this.initialData,
    this.isEdit = false,
    required this.sectionTitle});

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
  // Involved Causes controllers
  final TextEditingController _causeNameController = TextEditingController();
  final TextEditingController _causeRoleController = TextEditingController();
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
    'Quotes or Public Statements',
    'Involved Causes',
  ];
  String? _selectedPersonaType;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Set initial selected persona type based on sectionTitle
    _selectedPersonaType = widget.sectionTitle;

    if (widget.initialData != null) {
      final data = widget.initialData!;
      print(data);
      // Determine type from sectionType or initialData
      _selectedPersonaType = widget.sectionType.isNotEmpty
          ? widget.sectionType
          : (data['type'] ?? '');
      if (data['imageUrl'] != null) {
        if (data['imageUrl'] is XFile) {
          _pickedImage = data['imageUrl'];
        }
      }
      switch (_selectedPersonaType) {
        case 'Social Media Presence':
          _socialPlatformController.text = data['platform'] ?? '';
          _socialLinkController.text = data['link'] ?? '';
          _followerCountController.text = data['followers']?.toString() ?? '';
          break;
        case 'Public Image / Reputation':
          _publicImageTitleController.text = data['title'] ?? '';
          _publicImageDescController.text = data['description'] ?? '';
          break;
        case 'Fashion Style':
          _fashionStyleTitleController.text = data['title'] ?? '';
          _fashionStyleDescController.text = data['description'] ?? '';
          break;
        case 'Red Carpet Moments':
          _redCarpetTitleController.text = data['title'] ?? '';
          _redCarpetDescController.text = data['description'] ?? '';
          break;
        case 'Quotes or Public Statements':
          _quoteController.text = data['quote'] ?? '';
          _quoteContextController.text = data['context'] ?? '';
          break;
        case 'Involved Causes':
          _causeNameController.text = data['name'] ?? '';
          _causeRoleController.text = data['role'] ?? '';
          break;
      }
    }
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
    _causeNameController.dispose();
    _causeRoleController.dispose();
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
      case 'Involved Causes':
        data.addAll({
          'name': _causeNameController.text.trim(),
          'role': _causeRoleController.text.trim(),
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
      case 'Involved Causes':
        return [
          TextFormField(
            controller: _causeNameController,
            decoration: InputDecoration(
              labelText: 'Cause Name',
              prefixIcon: Icon(Icons.volunteer_activism),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Enter cause name' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _causeRoleController,
            decoration: InputDecoration(
              labelText: 'Role',
              prefixIcon: Icon(Icons.badge),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Enter role' : null,
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
    final secondaryTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final appPrimaryColor = const Color(0xFFD6AF0C); // Assuming this color is defined somewhere accessible

    final bool hasSectionType = (widget.sectionType.isNotEmpty);
    if (hasSectionType && _selectedPersonaType != widget.sectionType) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_selectedPersonaType != widget.sectionType) {
          setState(() {
            _selectedPersonaType = widget.sectionType;
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
                  // Fun Niche type dropdown
                  if (!hasSectionType)
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
                  if (hasSectionType)
                    DropdownButtonFormField<String>(
                      value: _selectedPersonaType,
                      decoration: InputDecoration(
                        labelText: 'Type',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: [DropdownMenuItem(
                        value: widget.sectionType,
                        child: Text(widget.sectionType),
                      )],
                      onChanged: null,
                      validator: (v) => v == null || v.isEmpty ? 'Select type' : null,
                    ),
                  const SizedBox(height: 14),
                  // Photo picker (hide for certain sections)
                  if (!['Social Media Presence', 'Public Image / Reputation', 'Quotes or Public Statements', 'Involved Causes'].contains(_selectedPersonaType))
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
                        child: (() {
                          if (_pickedImage != null) {
                            return Image.file(
                              File(_pickedImage!.path),
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            );
                          }
                          final imageUrl = widget.initialData != null
                              ? (widget.initialData!['imageUrl'] ?? widget.initialData!['image'] ?? widget.initialData!['photo'])
                              : null;
                          if (imageUrl != null && imageUrl.toString().isNotEmpty) {
                            final urlStr = imageUrl.toString();
                            if (urlStr.startsWith('http')) {
                              return Image.network(
                                urlStr,
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image, size: 36, color: Colors.grey)),
                              );
                            } else {
                              return Image.file(
                                File(urlStr),
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              );
                            }
                          }
                          return const Center(child: Icon(Icons.camera_alt, size: 36, color: Colors.grey));
                        })(),
                      ),
                    ),
                  const SizedBox(height: 10,),
                  if (!['Social Media Presence', 'Public Image / Reputation', 'Quotes or Public Statements', 'Involved Causes'].contains(_selectedPersonaType))
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
                      onPressed: _isLoading ? null : _submit,
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