import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart';
import 'app_buttons.dart';
import 'app_text_fields.dart';
import 'app_dropdown.dart';

class AddCareerHighlightsModal extends StatefulWidget {
  final void Function(Map<String, dynamic> careerHighlightItem) onAdd;
  const AddCareerHighlightsModal({super.key, required this.onAdd});

  @override
  State<AddCareerHighlightsModal> createState() => _AddCareerHighlightsModalState();
}

class _AddCareerHighlightsModalState extends State<AddCareerHighlightsModal> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCareerType;

  // Controllers for Debut Work
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Controllers for Awards
  final TextEditingController _awardNameController = TextEditingController();
  final TextEditingController _awardRoleController = TextEditingController();
  final TextEditingController _awardYearController = TextEditingController();
  final TextEditingController _valuePointsController = TextEditingController();

  // Controllers for Collaborations
  final TextEditingController _collaborationNameController = TextEditingController();
  final TextEditingController _collaboratorsController = TextEditingController();
  final TextEditingController _collaborationTypeController = TextEditingController();
  final TextEditingController _collaborationDescController = TextEditingController();

  final List<String> _careerTypes = ['Debut Work', 'Awards', 'Collaborations'];

  @override
  void dispose() {
    // Dispose Debut Work controllers
    _nameController.dispose();
    _yearController.dispose();
    _descriptionController.dispose();

    // Dispose Award controllers
    _awardNameController.dispose();
    _awardRoleController.dispose();
    _awardYearController.dispose();
    _valuePointsController.dispose();

    // Dispose Collaboration controllers
    _collaborationNameController.dispose();
    _collaboratorsController.dispose();
    _collaborationTypeController.dispose();
    _collaborationDescController.dispose();

    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    
    final Map<String, dynamic> data = {'type': _selectedCareerType};
    
    switch (_selectedCareerType) {
      case 'Debut Work':
        data.addAll({
          'name': _nameController.text.trim(),
          'year': _yearController.text.trim(),
          'description': _descriptionController.text.trim(),
        });
        break;
        
      case 'Awards':
        data.addAll({
          'awardName': _awardNameController.text.trim(),
          'role': _awardRoleController.text.trim(),
          'year': _awardYearController.text.trim(),
          'valuePoints': _valuePointsController.text.trim(),
        });
        break;
        
      case 'Collaborations':
        data.addAll({
          'name': _collaborationNameController.text.trim(),
          'collaborators': _collaboratorsController.text.trim(),
          'type': _collaborationTypeController.text.trim(),
          'description': _collaborationDescController.text.trim(),
        });
        break;
    }
    
    widget.onAdd(data);
    Navigator.of(context).pop();
  }

  List<Widget> _buildFieldsForType(String? type) {
    final loc = AppLocalizations.of(context)!;
    
    switch (type) {
      case 'Debut Work':
        return [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              prefixIcon: Icon(Icons.work),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Please enter name' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _yearController,
            decoration: const InputDecoration(
              labelText: 'Year',
              prefixIcon: Icon(Icons.calendar_today),
            ),
            keyboardType: TextInputType.number,
            validator: (v) => v == null || v.trim().isEmpty ? 'Please enter year' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 3,
            validator: (v) => v == null || v.trim().isEmpty ? 'Please enter description' : null,
          ),
        ];

      case 'Awards':
        return [
          TextFormField(
            controller: _awardNameController,
            decoration: const InputDecoration(
              labelText: 'Award Name',
              prefixIcon: Icon(Icons.emoji_events),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Please enter award name' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _awardRoleController,
            decoration: const InputDecoration(
              labelText: 'Role',
              prefixIcon: Icon(Icons.person),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Please enter role' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _awardYearController,
            decoration: const InputDecoration(
              labelText: 'Year',
              prefixIcon: Icon(Icons.calendar_today),
            ),
            keyboardType: TextInputType.number,
            validator: (v) => v == null || v.trim().isEmpty ? 'Please enter year' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _valuePointsController,
            decoration: const InputDecoration(
              labelText: 'Value Points',
              prefixIcon: Icon(Icons.star),
            ),
            keyboardType: TextInputType.number,
            validator: (v) => v == null || v.trim().isEmpty ? 'Please enter value points' : null,
          ),
        ];

      case 'Collaborations':
        return [
          TextFormField(
            controller: _collaborationNameController,
            decoration: const InputDecoration(
              labelText: 'Collaboration Name',
              prefixIcon: Icon(Icons.handshake),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Please enter collaboration name' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _collaboratorsController,
            decoration: const InputDecoration(
              labelText: 'Collaborators',
              prefixIcon: Icon(Icons.people),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Please enter collaborators' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _collaborationTypeController,
            decoration: const InputDecoration(
              labelText: 'Collaboration Type',
              prefixIcon: Icon(Icons.category),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Please enter collaboration type' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _collaborationDescController,
            decoration: const InputDecoration(
              labelText: 'Description',
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 3,
            validator: (v) => v == null || v.trim().isEmpty ? 'Please enter description' : null,
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
                  AppLocalizations.of(context)!.addCareerHighlight, // Updated string
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _selectedCareerType,
                  decoration: const InputDecoration(
                    labelText: 'Career Type',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: _careerTypes.map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedCareerType = val),
                  validator: (v) => v == null || v.isEmpty ? 'Please select a career type' : null,
                ),
                const SizedBox(height: 14),
                ..._buildFieldsForType(_selectedCareerType),
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