import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart';
import 'app_buttons.dart';
import 'app_date_picker.dart';
import 'app_text_fields.dart';
import 'app_dropdown.dart';

class AddWealthItemModal extends StatefulWidget {
  final void Function(Map<String, dynamic> wealthItem) onAdd;
  final String? sectionTitle;
  final String sectionType;
  final Map<String, dynamic>? initialData;
  final bool isEdit;

  const AddWealthItemModal({
    super.key,
    required this.sectionType,
    this.initialData,
    this.isEdit = false,
    required this.onAdd,
    this.sectionTitle});

  @override
  State<AddWealthItemModal> createState() => _AddWealthItemModalState();
}

class _AddWealthItemModalState extends State<AddWealthItemModal> {
  final _formKey = GlobalKey<FormState>();
  // Controllers for all possible fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _modelController = TextEditingController(); // car
  final TextEditingController _yearController = TextEditingController(); // car, art
  final TextEditingController _horsepowerController = TextEditingController(); // car
  final TextEditingController _priceController = TextEditingController(); // car, jewellery
  final TextEditingController _locationController = TextEditingController(); // house, property
  final TextEditingController _painterController = TextEditingController(); // art
  XFile? _pickedImage;

  final List<String> _categories = [
    'Car', 'House', 'Art', 'Property', 'Jewelry', 'Stocks', 'Business', 'Other'
  ];

  String? _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final data = widget.initialData!;
      print(data);
      // Determine type from sectionType or initialData
      _selectedCategory = widget.sectionType.isNotEmpty
          ? widget.sectionType
          : (data['type'] ?? '');
      if (data['imageUrl'] != null) {
        // If photo is a file path or network url, handle accordingly
        if (data['imageUrl'] is XFile) {
          _pickedImage = data['imageUrl'];
        } else if (data['imageUrl'] is String &&
            (data['imageUrl'] as String).isNotEmpty) {
          // For network image, you may want to show it in the picker
          // For demo, ignore as picker only supports local file
        }
      }

      switch (_selectedCategory) {
        case 'Car':
          _modelController.text = data['name'] ?? '';
          _yearController.text = data['year'] ?? '';
          _horsepowerController.text = data['horsepower'] ?? '';
          _priceController.text = data['price'] ?? '';
          _descController.text = data['description'] ?? '';
          break;
        case 'House':
          _locationController.text = data['name'] ?? data['location'] ?? '';
          _descController.text = data['description'] ?? '';
          _valueController.text = data['value'] ?? '';
          break;
        case 'Jewelry':
          _nameController.text = data['name'] ?? '';
          _descController.text = data['description'] ?? '';
          _priceController.text = data['price'] ?? '';
          break;
        case 'Art':
          _painterController.text = data['painter'] ?? '';
          _valueController.text = data['value'] ?? '';
          _yearController.text = data['year'] ?? '';
          _nameController.text = data['name'] ?? '';
          _descController.text = data['description'] ?? '';
          break;
        case 'Property':
          _locationController.text = data['location'] ?? '';
          _valueController.text = data['value'] ?? '';
          _descController.text = data['description'] ?? '';
          _nameController.text = data['name'] ?? '';
          break;
        case 'Stocks':
          _nameController.text = data['name'] ?? '';
          _valueController.text = data['value'] ?? '';
          break;
        case 'Business':
          _nameController.text = data['name'] ?? '';
          _valueController.text = data['value'] ?? '';
          break;
        case 'Other':
        default:
          _nameController.text = data['name'] ?? '';
          _descController.text = data['description'] ?? '';
          _valueController.text = data['value'] ?? '';
          break;
      }
    }
  }



  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _valueController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _horsepowerController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _painterController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final Map<String, dynamic> data = {'category': _selectedCategory};
    switch (_selectedCategory) {
      case 'Car':
        data.addAll({
          'model': _modelController.text.trim(),
          'year': _yearController.text.trim(),
          'horsepower': _horsepowerController.text.trim(),
          'price': _priceController.text.trim(),
          'description': _descController.text.trim(),
        });
        break;
      case 'House':
        data.addAll({
          'location': _locationController.text.trim(),
          'description': _descController.text.trim(),
          'value': _valueController.text.trim(),
        });
        break;
      case 'Jewelry':
        data.addAll({
          'name': _nameController.text.trim(),
          'description': _descController.text.trim(),
          'price': _priceController.text.trim(),
        });
        break;
      case 'Art':
        data.addAll({
          'painter': _painterController.text.trim(),
          'value': _valueController.text.trim(),
          'year': _yearController.text.trim(),
          'name': _nameController.text.trim(),
          'description': _descController.text.trim(),
        });
        break;
      case 'Property':
        data.addAll({
          'location': _locationController.text.trim(),
          'value': _valueController.text.trim(),
          'description': _descController.text.trim(),
          'name': _nameController.text.trim(),
        });
        break;
      case 'Stocks':
        data.addAll({
          'name': _nameController.text.trim(),
          'value': _valueController.text.trim(),
        });
        break;
      case 'Business':
        data.addAll({
          'name': _nameController.text.trim(),
          'value': _valueController.text.trim(),
        });
        break;
      case 'Other':
        data.addAll({
          'name': _nameController.text.trim(),
          'description': _descController.text.trim(),
          'value': _valueController.text.trim(),
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

  List<Widget> _buildFieldsForCategory(String? category) {
    final loc = AppLocalizations.of(context)!;
    switch (category) {
      case 'Car':
        return [
          TextFormField(
            controller: _modelController,
            decoration: InputDecoration(
              labelText: 'Car Model',
              prefixIcon: Icon(Icons.directions_car),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Enter car model' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _yearController,
            decoration: InputDecoration(
              labelText: 'Year',
              prefixIcon: Icon(Icons.calendar_today),
            ),
            readOnly: true,
            onTap: () async {
              final picked = await CustomDatePicker.show(context);
              if (picked != null) {
                setState(() {
                  _yearController.text = picked.year.toString();
                });
              }
            },
            validator: (v) => v == null || v.trim().isEmpty ? 'Enter year' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _horsepowerController,
            decoration: InputDecoration(
              labelText: 'Horsepower',
              prefixIcon: Icon(Icons.speed),
            ),
            keyboardType: TextInputType.number,
            validator: (v) => v == null || v.trim().isEmpty ? 'Enter horsepower' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _priceController,
            decoration: InputDecoration(
              labelText: 'Price',
              prefixIcon: Icon(Icons.attach_money),
            ),
            keyboardType: TextInputType.number,
            validator: (v) => v == null || v.trim().isEmpty ? 'Enter price' : null,
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
      case 'House':
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
            controller: _valueController,
            decoration: InputDecoration(
              labelText: loc.estimatedValueOptional,
              prefixIcon: Icon(Icons.attach_money),
            ),
            keyboardType: TextInputType.number,
          ),
        ];
      case 'Jewelry':
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
            controller: _priceController,
            decoration: InputDecoration(
              labelText: 'Price',
              prefixIcon: Icon(Icons.attach_money),
            ),
            keyboardType: TextInputType.number,
            validator: (v) => v == null || v.trim().isEmpty ? 'Enter price' : null,
          ),
        ];
      case 'Art':
        return [
          TextFormField(
            controller: _painterController,
            decoration: InputDecoration(
              labelText: 'Painter',
              prefixIcon: Icon(Icons.brush),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Enter painter' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _valueController,
            decoration: InputDecoration(
              labelText: loc.estimatedValueOptional,
              prefixIcon: Icon(Icons.attach_money),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _yearController,
            decoration: InputDecoration(
              labelText: 'Year',
              prefixIcon: Icon(Icons.calendar_today),
            ),
            readOnly: true,
            onTap: () async {
              final picked = await CustomDatePicker.show(context);
              if (picked != null) {
                setState(() {
                  _yearController.text = picked.year.toString();
                });
              }
            },
            validator: (v) => v == null || v.trim().isEmpty ? 'Enter year' : null,
          ),
          const SizedBox(height: 14),
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
        ];
      case 'Property':
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
            controller: _valueController,
            decoration: InputDecoration(
              labelText: loc.estimatedValueOptional,
              prefixIcon: Icon(Icons.attach_money),
            ),
            keyboardType: TextInputType.number,
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
            controller: _nameController,
            decoration: InputDecoration(
              labelText: loc.name,
              prefixIcon: Icon(Icons.label),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? loc.enterName : null,
          ),
        ];
      case 'Stocks':
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
            controller: _valueController,
            decoration: InputDecoration(
              labelText: loc.estimatedValueOptional,
              prefixIcon: Icon(Icons.attach_money),
            ),
            keyboardType: TextInputType.number,
          ),
        ];
      case 'Business':
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
            controller: _valueController,
            decoration: InputDecoration(
              labelText: loc.estimatedValueOptional,
              prefixIcon: Icon(Icons.attach_money),
            ),
            keyboardType: TextInputType.number,
          ),
        ];
      case 'Other':
      default:
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
            controller: _valueController,
            decoration: InputDecoration(
              labelText: loc.estimatedValueOptional,
              prefixIcon: Icon(Icons.attach_money),
            ),
            keyboardType: TextInputType.number,
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final appPrimaryColor = const Color(0xFFD6AF0C);

    final bool hasSectionTitle = (widget.sectionType != null && widget.sectionType!.isNotEmpty);
    if (hasSectionTitle && _selectedCategory != widget.sectionType) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_selectedCategory != widget.sectionType) {
          setState(() {
            _selectedCategory = widget.sectionType;
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
                    widget.sectionTitle ?? AppLocalizations.of(context)!.addWealthItem,
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
                  const SizedBox(height: 18),
                  AppDropdownFormField<String>(
                    labelText: AppLocalizations.of(context)!.category,
                    icon: Icons.category,
                    value: _selectedCategory,
                    items: _categories.map((cat) => DropdownMenuItem(
                      value: cat,
                      child: Text(AppLocalizations.of(context)!.categoryValue(cat)),
                    )).toList(),
                    onChanged: hasSectionTitle ? null : (val) => setState(() => _selectedCategory = val),
                    validator: (v) => v == null || v.isEmpty ? AppLocalizations.of(context)!.selectCategory : null,
                  ),
                  const SizedBox(height: 14),
                  ..._buildFieldsForCategory(_selectedCategory),
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
