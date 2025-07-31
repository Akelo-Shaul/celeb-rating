import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:celebrating/services/user_service.dart';
import 'package:celebrating/app_state.dart';
import '../l10n/app_localizations.dart';
import '../models/user.dart';
import '../l10n/supported_languages.dart';

import '../services/auth_service.dart';
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

  // Filter state for leaderboard
  String _selectedLocation = 'All Locations';
  String _selectedCategory = 'All Categories';

  // Filter options
  final List<String> _locationOptions = [
    'All Locations',
    'United States',
    'Canada',
    'United Kingdom',
    'Germany',
    'France',
    'Italy',
    'Spain',
    'Portugal',
    'Argentina',
    'Brazil',
    'Mexico',
    'Australia',
    'Japan',
    'South Korea',
    'China',
    'India',
    'Nigeria',
    'South Africa',
    'Kenya',
  ];

  final List<String> _categoryOptions = [
    'All Categories',
    'Music',
    'Acting',
    'Sports',
    'Business',
    'Entertainment',
    'Fashion',
    'Technology',
    'Politics',
    'Science',
    'Art',
  ];

  // Dummy celebrity data for leaderboard
  final List<Map<String, dynamic>> _celebrities = [
    {
      'name': 'Taylor Swift',
      'category': 'Music',
      'country': 'United States',
      'followers': '250.5M',
      'score': 98,
      'trend': 'up',
      'image': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face',
    },
    {
      'name': 'Beyoncé',
      'category': 'Music',
      'country': 'United States',
      'followers': '232.1M',
      'score': 97,
      'trend': 'up',
      'image': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face',
    },
    {
      'name': 'Dwayne Johnson',
      'category': 'Acting',
      'country': 'United States',
      'followers': '210.7M',
      'score': 95,
      'trend': 'neutral',
      'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
    },
    {
      'name': 'Ariana Grande',
      'category': 'Music',
      'country': 'United States',
      'followers': '190.3M',
      'score': 93,
      'trend': 'down',
      'image': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&h=150&fit=crop&crop=face',
    },
    {
      'name': 'Cristiano Ronaldo',
      'category': 'Sports',
      'country': 'Portugal',
      'followers': '187.8M',
      'score': 92,
      'trend': 'up',
      'image': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
    },
    {
      'name': 'Kylie Jenner',
      'category': 'Business',
      'country': 'United States',
      'followers': '182.4M',
      'score': 90,
      'trend': 'down',
      'image': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&h=150&fit=crop&crop=face',
    },
    {
      'name': 'Selena Gomez',
      'category': 'Music',
      'country': 'United States',
      'followers': '178.9M',
      'score': 89,
      'trend': 'up',
      'image': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150&h=150&fit=crop&crop=face',
    },
    {
      'name': 'Justin Bieber',
      'category': 'Music',
      'country': 'Canada',
      'followers': '165.2M',
      'score': 87,
      'trend': 'neutral',
      'image': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&h=150&fit=crop&crop=face',
    },
    {
      'name': 'Kim Kardashian',
      'category': 'Business',
      'country': 'United States',
      'followers': '158.7M',
      'score': 85,
      'trend': 'down',
      'image': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face',
    },
    {
      'name': 'Leo Messi',
      'category': 'Sports',
      'country': 'Argentina',
      'followers': '152.3M',
      'score': 84,
      'trend': 'up',
      'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
    },
  ];

  List<Map<String, dynamic>> get _filteredCelebrities {
    return _celebrities.where((celebrity) {
      bool locationMatch = _selectedLocation == 'All Locations' || 
                          celebrity['country'] == _selectedLocation;
      bool categoryMatch = _selectedCategory == 'All Categories' || 
                          celebrity['category'] == _selectedCategory;
      return locationMatch && categoryMatch;
    }).toList();
  }

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
      await AuthService.instance.login(_loginUsername, _loginPassword);
      if (!mounted) return;
      context.goNamed('feed');
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
      setState(() {
        isSubmitting = false;
        errorMessage = null;
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          context.goNamed('onboarding');
          setState(() {
            errorMessage = null;
          });
        }
      });
    } catch (e) {
      setState(() {
        isSubmitting = false;
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _openCamera() async {
    final result = await context.pushNamed<XFile>(
      'camera',
      queryParameters: {'returnRoute': '/auth'},
    );
    if (result != null && mounted) {
      setState(() {
        _selectedImage = result;
      });
    }
  }

  Widget _buildLeaderboard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  'Celebrity Leaderboard',
                  style: TextStyle(
                    color: Colors.purple[400],
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: isDark ? Colors.white : Colors.black,
                ),
                onPressed: () {
                  // TODO: Implement search
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.filter_list,
                  color: isDark ? Colors.white : Colors.black,
                ),
                onPressed: _showFilterDialog,
              ),
            ],
          ),
          Text(
            'Tracking the most influential celebrities worldwide',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          
          // Leaderboard Table
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: _filteredCelebrities.asMap().entries.map((entry) {
                  final index = entry.key;
                  final celebrity = entry.value;
                  final rank = index + 1;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Rank
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: rank == 1 ? Colors.amber : 
                                   rank == 2 ? Colors.grey[400] : 
                                   rank == 3 ? Colors.orange[700] : 
                                   Colors.grey[600],
                          ),
                          child: Center(
                            child: Text(
                              '$rank',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Celebrity Info
                        Expanded(
                          child: Row(
                            children: [
                              // Profile Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  celebrity['image'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.grey[600],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              
                              // Name and Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      celebrity['name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '${celebrity['category']} • ${celebrity['country']}',
                                      style: TextStyle(
                                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Followers
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              celebrity['followers'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Followers',
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        
                        // Score
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${celebrity['score']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Score',
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        
                        // Trend
                        Icon(
                          celebrity['trend'] == 'up' ? Icons.trending_up :
                          celebrity['trend'] == 'down' ? Icons.trending_down :
                          Icons.remove,
                          color: celebrity['trend'] == 'up' ? Colors.green :
                                 celebrity['trend'] == 'down' ? Colors.red :
                                 Colors.grey,
                          size: 20,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: isDark ? Colors.grey[900] : Colors.white,
              title: Text(
                'Filter Leaderboard',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Location Filter
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _selectedLocation,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            dropdownColor: isDark ? Colors.grey[800] : Colors.white,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            items: _locationOptions.map((String location) {
                              return DropdownMenuItem<String>(
                                value: location,
                                child: Text(location),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedLocation = newValue!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Category Filter
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Category',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            dropdownColor: isDark ? Colors.grey[800] : Colors.white,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            items: _categoryOptions.map((String category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedCategory = newValue!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    this.setState(() {
                      _selectedLocation = _selectedLocation;
                      _selectedCategory = _selectedCategory;
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
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
                        Image.asset(
                          'assets/images/profile_placeholder.png',
                          height: 130,
                          width: 130,
                        ),
                      ),
                    ),
                    Positioned(
                      right: -10,
                      top: -10,
                      child: IconButton(
                        icon: _selectedImage != null ? Icon(
                          Icons.edit_square,
                          color: const Color(0xFFD6AF0C),
                          size: 35,
                        ): Icon(Icons.camera_alt, size: 35, color:  const Color(0xFFD6AF0C)),
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final currentLocale = appState.locale;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 120,
        leading: Image.asset(
          'assets/images/celebratinglogo.png',
          fit: BoxFit.fitHeight,
        ),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<SupportedLanguage>(
              icon: Icon(Icons.language, color: isDark ? Colors.white : Colors.black),
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
            icon: Icon(
              Icons.brightness_6,
              color: isDark ? Colors.white : Colors.black,
            ),
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
                  _buildLeaderboard(),
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