import 'package:celebrating/l10n/app_localizations.dart';
// auth_screen.dart

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:celebrating/utils/route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:celebrating/services/user_service.dart';
import 'package:celebrating/app_state.dart';
import '../models/user.dart';
import '../l10n/supported_languages.dart';

import '../widgets/app_buttons.dart';
import '../widgets/app_dropdown.dart';
import '../widgets/app_text_fields.dart';
import '../widgets/error_message.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKeyLogin = GlobalKey<FormState>();
  final _formKeyRegister = GlobalKey<FormState>();

  String _loginUsername = '';
  String _loginPassword = '';
  String? _registerFirstName;
  String? _registerLastName;
  String? _registerEmail;
  String? _registerUsername;
  String? _registerPassword;
  String? _registerConfirmPassword;
  String? _registerRole;
  XFile? _selectedImage;
  String? errorMessage;
  bool isSubmitting = false;
  final PageController _pageController = PageController();

  void _navigateToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
    setState(() {
      errorMessage = null;
      isSubmitting = false;
    });
  }

  void _submitLogin() async {
    Navigator.pushReplacementNamed(context, '/onboarding');
    if (!_formKeyLogin.currentState!.validate()) {
      setState(() {
        isSubmitting = false;
        errorMessage = null;
      });
      return;
    }
    _formKeyLogin.currentState!.save();
    setState(() {
      isSubmitting = true;
      errorMessage = null;
    });
    try {
      final token = await UserService.login(_loginUsername, _loginPassword);
      setState(() {
        isSubmitting = false;
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        isSubmitting = false;
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            errorMessage = null;
          });
        }
      });
    }
  }

  void _submitRegister() async {
    setState(() {
      errorMessage = null;
      isSubmitting = false;
    });
    if (_selectedImage == null) {
      setState(() {
        errorMessage = 'Please select or take a profile photo.';
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            errorMessage = null;
          });
        }
      });
      return;
    }
    if (!_formKeyRegister.currentState!.validate()) {
      setState(() {
        isSubmitting = false;
        errorMessage = null;
      });
      return;
    }
    _formKeyRegister.currentState!.save();
    // Check all required fields AFTER saving form
    if (_registerFirstName == null || _registerFirstName!.isEmpty ||
        _registerLastName == null || _registerLastName!.isEmpty ||
        _registerEmail == null || _registerEmail!.isEmpty ||
        _registerUsername == null || _registerUsername!.isEmpty ||
        _registerPassword == null || _registerPassword!.isEmpty ||
        _registerConfirmPassword == null || _registerConfirmPassword!.isEmpty) {
      setState(() {
        errorMessage = 'Please fill in all required fields.';
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            errorMessage = null;
          });
        }
      });
      return;
    }
    if (_registerPassword != _registerConfirmPassword) {
      setState(() {
        errorMessage = 'Passwords do not match';
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            errorMessage = null;
          });
        }
      });
      return;
    }
    setState(() {
      isSubmitting = true;
    });
    try {

      print("#########################%%%%%%%%%%%%%%%*************%%%%%%#####");
      print('username: [33m$_registerUsername[0m, password: [33m$_registerPassword[0m, email: [33m$_registerEmail[0m, role: [33m$_registerRole[0m, fullName: [33m${_registerFirstName ?? ''} ${_registerLastName ?? ''}[0m, profileImage: [33m${_selectedImage?.path}[0m');
      final user = await UserService.register(
        User(
          username: _registerUsername ?? '',
          password: _registerPassword ?? '',
          email: _registerEmail ?? '',
          role: _registerRole ?? 'user',
          fullName: '${_registerFirstName ?? ''} ${_registerLastName ?? ''}',
          profileImage: _selectedImage?.path,
        ),
      );
      print("#########################%%%%%%%%%%%%%%%*************%%%%%%#####");
      print(user);
      setState(() {
        isSubmitting = false;
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        isSubmitting = false;
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            errorMessage = null;
          });
        }
      });
    }
  }

  Future<void> _openCamera() async {
    final result = await Navigator.pushNamed(context, cameraScreen);
    if (result is XFile) {
      setState(() {
        _selectedImage = result;
      });
    }
  }

  Widget _buildLoginForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKeyLogin,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppTextFormField(
              labelText: AppLocalizations.of(context)!.emailOrUsername,
              icon: Icons.person_outline,
              onSaved: (v) => _loginUsername = v ?? '',
              validator: (v) => v == null || v.isEmpty ? AppLocalizations.of(context)!.usernameRequired : null,
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              labelText: AppLocalizations.of(context)!.password,
              icon: Icons.lock_outline,
              isPassword: true,
              onSaved: (v) => _loginPassword = v ?? '',
              validator: (v) => v == null || v.isEmpty ? AppLocalizations.of(context)!.passwordRequired : null,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: AppLocalizations.of(context)!.signIn,
              isLoading: isSubmitting,
              onPressed: _submitLogin,
            ),
            const SizedBox(height: 20),
            AppButton(
              text: AppLocalizations.of(context)!.register,
              onPressed: () => _navigateToPage(1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKeyRegister,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _openCamera,
              child: Stack(
                  children: [
                    Positioned(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: _selectedImage != null ?
                        SizedBox(
                          height: 130,
                          width: 130,
                          child: Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
                        ) :
                        const Center(
                          child: Icon(Icons.camera_alt, size: 48, color: Colors.grey),
                        ),
                      ),
                    ),
                    if (_selectedImage != null)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: IconButton(
                          icon: Icon(
                            Icons.edit_square,
                            color: const Color(0xFFD6AF0C),
                            size: 40,
                          ),
                          onPressed: _openCamera,
                        ),
                      ),
                  ]
              ),
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              labelText: AppLocalizations.of(context)!.firstName,
              icon: Icons.person_outline,
              onSaved: (v) => _registerFirstName = v,
              validator: (v) => v == null || v.isEmpty ? AppLocalizations.of(context)!.firstNameRequired : null,
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              labelText: AppLocalizations.of(context)!.lastName,
              icon: Icons.person_outline,
              onSaved: (v) => _registerLastName = v,
              validator: (v) => v == null || v.isEmpty ? AppLocalizations.of(context)!.lastNameRequired : null,
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              labelText: AppLocalizations.of(context)!.email,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              onSaved: (v) => _registerEmail = v,
              validator: (v) {
                if (v == null || v.isEmpty) return AppLocalizations.of(context)!.enterValidEmail;
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              labelText: AppLocalizations.of(context)!.username,
              icon: Icons.person_outline,
              onSaved: (v) => _registerUsername = v,
              validator: (v) => v == null || v.isEmpty ? AppLocalizations.of(context)!.usernameRequired : null,
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              labelText: AppLocalizations.of(context)!.password,
              icon: Icons.lock_outline,
              isPassword: true,
              onSaved: (v) => _registerPassword = v,
              validator: (v) => v == null || v.length < 6 ? AppLocalizations.of(context)!.passwordMinLength : null,
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              labelText: AppLocalizations.of(context)!.confirmPassword,
              icon: Icons.lock_outline,
              isPassword: true,
              onSaved: (v) => _registerConfirmPassword = v,
              validator: (v) => v == null || v.isEmpty ? AppLocalizations.of(context)!.confirmPasswordRequired : null,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: AppLocalizations.of(context)!.signUp,
              isLoading: isSubmitting,
              onPressed: _submitRegister,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppLocalizations.of(context)!.alreadyHaveAccount),
                TextButton(
                  onPressed: () => _navigateToPage(0),
                  child: Text(
                    AppLocalizations.of(context)!.signIn,
                    style: const TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final currentLocale = appState.locale;
    return Scaffold(
      appBar: AppBar(
        title: Text('Celebrating'),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<SupportedLanguage>(
              icon: const Icon(Icons.language, color: Colors.white),
              value: supportedLanguages.firstWhere(
                (l) => l.code == currentLocale?.languageCode,
                orElse: () => supportedLanguages[0],
              ),
              items: supportedLanguages.map((lang) => DropdownMenuItem(
                value: lang,
                child: Text('${lang.flag} ${lang.label}'),
              )).toList(),
              onChanged: (lang) {
                if (lang != null) appState.setLocale(Locale(lang.code));
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: appState.toggleTheme,
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            if (errorMessage != null)
              ErrorMessageBox(message: errorMessage!),
            Center(
              child: Text(
                _pageController.hasClients && _pageController.page == 1
                  ? AppLocalizations.of(context)!.joinTheCommunitySignUp
                  : AppLocalizations.of(context)!.joinTheCommunitySignIn,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  // You might update the header based on the current page,
                  // but for now, we'll keep a consistent header.
                },
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildLoginForm(),
                  _buildRegisterForm(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}