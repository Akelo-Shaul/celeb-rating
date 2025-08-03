import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart';
import 'app_buttons.dart';
import 'app_date_picker.dart';
import 'app_text_fields.dart';
import 'app_dropdown.dart';

class AddFunNicheModal extends StatefulWidget {
  final void Function(Map<String, dynamic> funNicheItem) onAdd;
  final String sectionTitle;
  final String sectionType;
  final Map<String, dynamic>? initialData;
  final bool isEdit;
  const AddFunNicheModal({
    super.key,
    required this.onAdd,
    required this.sectionType,
    this.initialData,
    this.isEdit = false, required this.sectionTitle,});

  @override
  State<AddFunNicheModal> createState() => _AddFunNicheModalState();
}

class _AddFunNicheModalState extends State<AddFunNicheModal> {
  final _formKey = GlobalKey<FormState>();
  // Controllers for all possible fields
  final TextEditingController _nameController = TextEditingController(); // Tattoos, Pets, Hidden Talents, Favorite Things (item)
  final TextEditingController _descController = TextEditingController(); // All
  final TextEditingController _bodyPartController = TextEditingController(); // Tattoos
  final TextEditingController _speciesController = TextEditingController(); // Pets
  final TextEditingController _breedController = TextEditingController(); // Pets
  final TextEditingController _categoryController = TextEditingController(); // Favorite Things (food, music etc.)
  final TextEditingController _reasonController = TextEditingController(); // Favorite Things
  final TextEditingController _startYearController = TextEditingController(); // Hidden Talents
  final TextEditingController _fanTheoryTitleController = TextEditingController(); // Fan Theories
  final TextEditingController _fanInteractionTypeController = TextEditingController(); // Fan Interactions

  XFile? _pickedImage;
  DateTime? _selectStartDate;
  bool _isLoading = false;

  final TextEditingController _hobbyNameController = TextEditingController();
  final TextEditingController _hobbyDescController = TextEditingController();
  final TextEditingController _hobbyCategoryController = TextEditingController();
  final List<String> _funNicheTypes = [
    'Tattoos or Unique Physical Traits', 'Pets', 'Favorite Things', 'Hidden Talents', 'Fan Theories or Fan Interactions', 'Hobbies'
  ];
  String? _selectedFunNicheType;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final data = widget.initialData!;
      print(data);
      // Determine type from sectionType or initialData
      _selectedFunNicheType = widget.sectionType.isNotEmpty
          ? widget.sectionType
          : (data['type'] ?? '');
      if (data['imageUrl'] != null) {
        // If photo is a file path or network url, handle accordingly
        if (data['imageUrl'] is XFile) {
          _pickedImage = data['imageUrl'];
        } else if (data['imageUrl'] is String && (data['imageUrl'] as String).isNotEmpty) {
          // For network image, you may want to show it in the picker
          // For demo, ignore as picker only supports local file
        }
      }

      // Prefill fields for each type using user_service.dart structure
      switch (_selectedFunNicheType) {
        case 'Tattoos or Unique Physical Traits':
          _nameController.text = data['name'] ?? data['title'] ?? '';
          _bodyPartController.text = data['bodyPart'] ?? '';
          _descController.text = data['description'] ?? '';
          break;
        case 'Pets':
          _nameController.text = data['name'] ?? '';
          _speciesController.text = data['type'] ?? data['species'] ?? '';
          _breedController.text = data['breed'] ?? '';
          _descController.text = data['description'] ?? '';
          break;
        case 'Favorite Things':
          _categoryController.text = data['category'] ?? '';
          _nameController.text = data['item'] ?? data['name'] ?? '';
          _reasonController.text = data['reason'] ?? '';
          _descController.text = data['description'] ?? '';
          break;
        case 'Hidden Talents':
          _nameController.text = data['name'] ?? '';
          _descController.text = data['description'] ?? '';
          _startYearController.text = data['startYear'] ?? '';
          break;
        case 'Fan Theories or Fan Interactions':
          _fanTheoryTitleController.text = data['theory'] ?? data['interaction'] ?? '';
          _fanInteractionTypeController.text = data['interactionType'] ?? '';
          _descController.text = data['description'] ?? '';
          break;
        case 'Hobbies':
          _hobbyNameController.text = data['name'] ?? '';
          _hobbyCategoryController.text = data['category'] ?? '';
          _hobbyDescController.text = data['description'] ?? '';
          break;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _bodyPartController.dispose();
    _speciesController.dispose();
    _breedController.dispose();
    _categoryController.dispose();
    _reasonController.dispose();
    _startYearController.dispose();
    _fanTheoryTitleController.dispose();
    _fanInteractionTypeController.dispose();
    _hobbyNameController.dispose();
    _hobbyDescController.dispose();
    _hobbyCategoryController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final Map<String, dynamic> data = {'type': _selectedFunNicheType};
    switch (_selectedFunNicheType) {
      case 'Tattoos or Unique Physical Traits':
        data.addAll({
          'name': _nameController.text.trim(),
          'bodyPart': _bodyPartController.text.trim(),
          'description': _descController.text.trim(),
        });
        break;
      case 'Pets':
        data.addAll({
          'name': _nameController.text.trim(),
          'species': _speciesController.text.trim(),
          'breed': _breedController.text.trim(),
          'description': _descController.text.trim(),
        });
        break;
      case 'Favorite Things':
        data.addAll({
          'category': _categoryController.text.trim(),
          'item': _nameController.text.trim(),
          'reason': _reasonController.text.trim(),
          'description': _descController.text.trim(),
        });
        break;
      case 'Hidden Talents':
        data.addAll({
          'name': _nameController.text.trim(),
          'description': _descController.text.trim(),
          'startYear': _startYearController.text.trim(),
        });
        break;
      case 'Fan Theories or Fan Interactions':
        data.addAll({
          'title': _fanTheoryTitleController.text.trim(),
          'interactionType': _fanInteractionTypeController.text.trim(),
          'description': _descController.text.trim(),
        });
        break;
      case 'Hobbies':
        data.addAll({
          'name': _hobbyNameController.text.trim(),
          'category': _hobbyCategoryController.text.trim(),
          'description': _hobbyDescController.text.trim(),
          'image': _pickedImage?.path,
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
      case 'Tattoos or Unique Physical Traits':
        return [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Trait/Tattoo Name',
              prefixIcon: Icon(Icons.label),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Enter trait or tattoo name' : null,
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
      case 'Pets':
        return [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: loc.name,
              prefixIcon: Icon(Icons.pets),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? loc.enterName : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _speciesController,
            decoration: const InputDecoration(
              labelText: 'Species (e.g., Dog, Cat)',
              prefixIcon: Icon(Icons.category),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Enter species' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _breedController,
            decoration: const InputDecoration(
              labelText: 'Breed (Optional)',
              prefixIcon: Icon(Icons.pets),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _descController,
            decoration: InputDecoration(
              labelText: loc.description,
              prefixIcon: Icon(Icons.description),
            ),
          ),
        ];
      case 'Favorite Things':
        return [
          TextFormField(
            controller: _categoryController,
            decoration: const InputDecoration(
              labelText: 'Category (e.g., Food, Music, Movie)',
              prefixIcon: Icon(Icons.category),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Enter category' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Item Name',
              prefixIcon: Icon(Icons.label),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Enter item name' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _reasonController,
            decoration: const InputDecoration(
              labelText: 'Reason for liking',
              prefixIcon: Icon(Icons.ondemand_video_sharp),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Enter reason' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _descController,
            decoration: InputDecoration(
              labelText: loc.description,
              prefixIcon: Icon(Icons.description),
            ),
          ),
        ];
      case 'Hidden Talents':
        return [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: loc.name,
              prefixIcon: Icon(Icons.lightbulb_outline),
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
              labelText: 'Since Year (Optional)',
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

      case 'Hobbies':
        return [
          TextFormField(
            controller: _hobbyNameController,
            decoration: InputDecoration(
              labelText: 'Hobby Name',
              prefixIcon: Icon(Icons.sports_soccer),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Enter hobby name' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _hobbyCategoryController,
            decoration: InputDecoration(
              labelText: 'Category (e.g., Sport, Art, Music)',
              prefixIcon: Icon(Icons.category),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Enter category' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _hobbyDescController,
            decoration: InputDecoration(
              labelText: 'Description',
              prefixIcon: Icon(Icons.description),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Enter description' : null,
          ),
        ];
      case 'Fan Theories or Fan Interactions':
        return [
          TextFormField(
            controller: _fanTheoryTitleController,
            decoration: const InputDecoration(
              labelText: 'Title (e.g., Fan Theory:..., Fan Interaction:...)',
              prefixIcon: Icon(Icons.lightbulb),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Enter title' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _fanInteractionTypeController,
            decoration: const InputDecoration(
              labelText: 'Interaction Type (e.g., Q&A, Meet-and-Greet)',
              prefixIcon: Icon(Icons.people_alt),
            ),
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
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final appPrimaryColor = const Color(0xFFD6AF0C); // Assuming this color is defined somewhere accessible

    final bool hasSectionType = (widget.sectionType.isNotEmpty);
    if (hasSectionType && _selectedFunNicheType != widget.sectionType) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_selectedFunNicheType != widget.sectionType) {
          setState(() {
            _selectedFunNicheType = widget.sectionType;
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
                      value: _selectedFunNicheType,
                      decoration: InputDecoration(
                        labelText: 'Type',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _funNicheTypes.map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      )).toList(),
                      onChanged: (val) => setState(() => _selectedFunNicheType = val),
                      validator: (v) => v == null || v.isEmpty ? 'Select type' : null,
                    ),
                  if (hasSectionType)
                    DropdownButtonFormField<String>(
                      value: _selectedFunNicheType,
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
                      child: (() {
                        if (_pickedImage != null) {
                          return Image.file(
                            File(_pickedImage!.path),
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          );
                        }
                        // Prefer imageUrl, fallback to image, fallback to photo
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
                  ..._buildFieldsForType(_selectedFunNicheType),
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