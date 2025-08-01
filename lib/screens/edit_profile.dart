
import 'dart:io';
import 'package:celebrating/widgets/app_buttons.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}


class _EditProfileState extends State<EditProfile> {
  final GlobalKey<FormState> _formKeyUpdateProfile = GlobalKey<FormState>();
  final TextEditingController _stageNameController = TextEditingController();
  final TextEditingController _celebrityFieldController = TextEditingController();
  final TextEditingController _spiritualityController = TextEditingController();
  final TextEditingController _netWorthController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _dietController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  File? _selectedImage;
  User? user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    // Replace with actual logic to get current user id
    final String currentUserId = 'currentLoggedInUserId';
    final fetchedUser = await UserService.fetchUser(currentUserId, isCelebrity: true);
    setState(() {
      user = fetchedUser;
      _stageNameController.text = fetchedUser.username ?? '';
      _emailController.text = fetchedUser.email ?? '';
      if (fetchedUser is CelebrityUser) {
        _celebrityFieldController.text = fetchedUser.occupation ?? '';
        _spiritualityController.text = fetchedUser.spirituality ?? '';
        _netWorthController.text = fetchedUser.netWorth ?? '';
        _bioController.text = fetchedUser.bio ?? '';
        _websiteController.text = fetchedUser.website ?? '';
        _dietController.text = fetchedUser.diet ?? '';
        _nationalityController.text = fetchedUser.nationality ?? '';
      } else {
        _celebrityFieldController.text = '';
        _spiritualityController.text = '';
        _netWorthController.text = '';
        _bioController.text = '';
        _websiteController.text = '';
        _dietController.text = '';
        _nationalityController.text = '';
      }
      _loading = false;
    });
  }

  @override
  void dispose() {
    _stageNameController.dispose();
    _celebrityFieldController.dispose();
    _spiritualityController.dispose();
    _netWorthController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    _dietController.dispose();
    _nationalityController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ImageProvider<Object>? profileImage = _selectedImage != null
        ? FileImage(_selectedImage!)
        : (user != null && user!.profileImageUrl != null && user!.profileImageUrl!.isNotEmpty
            ? NetworkImage(user!.profileImageUrl!)
            : null);

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Account Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton(
              onPressed: () {
                // Add save logic here
              },
              child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: _formKeyUpdateProfile,
                child: ListView(
                  children: [
                    const SizedBox(height: 24),
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: profileImage != null
                                ? Image(
                                    image: profileImage,
                                    height: 130,
                                    width: 130,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    'assets/images/profile_placeholder.png',
                                    height: 130,
                                    width: 130,
                                  ),
                          ),
                          Positioned(
                            bottom: 0,
                            child: TextButton.icon(
                              style: TextButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.85),
                                foregroundColor: Theme.of(context).colorScheme.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              ),
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('Edit Image', style: TextStyle(fontWeight: FontWeight.w500)),
                              onPressed: () async {
                                // Pick image from gallery
                                final picked = await _pickImageFromGallery();
                                if (picked != null) {
                                  setState(() {
                                    _selectedImage = picked;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _stageNameController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.stageName,
                        prefixIcon: Icon(Icons.mic),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.email,
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (user is CelebrityUser) ...[
                      TextFormField(
                        controller: _celebrityFieldController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.celebrityField,
                          prefixIcon: Icon(Icons.military_tech),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _spiritualityController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.spirituality,
                          prefixIcon: Icon(Icons.back_hand_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _netWorthController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.netWorth,
                          prefixIcon: Icon(Icons.money),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _bioController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.bio,
                          prefixIcon: Icon(Icons.info_outline),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _websiteController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.website,
                          prefixIcon: Icon(Icons.link),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _dietController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.diet,
                          prefixIcon: Icon(Icons.restaurant),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nationalityController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.nationality,
                          prefixIcon: Icon(Icons.flag),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<File?> _pickImageFromGallery() async {
    // Use image_picker package
    try {
      // Import image_picker at the top of the file:
      // import 'package:image_picker/image_picker.dart';
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      // Handle error or show a snackbar
    }
    return null;
  }
}
