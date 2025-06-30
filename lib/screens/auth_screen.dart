// auth_screen.dart

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
  String? _registerSex;
  String? _registerDay;
  String? _registerMonth;
  String? _registerYear;
  String? _registerPhoneNumber;
  String? _registerEmail;
  String? _registerUsername;
  String? _registerPassword;
  String? _registerConfirmPassword;
  String? _registerRole;
  String? _registerFullName;

  bool _agreeToNewsletter = false;
  bool _agreeToTerms = false;

  String? errorMessage; // For general/backend errors
  bool isSubmitting = false;

  final PageController _pageController = PageController();

  // --- Dropdown Data (Placeholder) ---
  final List<String> _sexOptions = ['Male', 'Female', 'Other'];
  final List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  final List<String> _days = List.generate(31, (index) => (index + 1).toString());
  final List<String> _years = List.generate(100, (index) => (DateTime.now().year - index).toString());

  final List<String> _countries = ['USA', 'Canada', 'UK', 'Kenya', 'Germany'];
  final Map<String, List<String>> _states = {
    'USA': ['California', 'Texas', 'New York'],
    'Kenya': ['Nairobi', 'Mombasa', 'Kisumu'],
    'UK': ['England', 'Scotland', 'Wales'],
    'Canada': ['Ontario', 'Quebec'],
    'Germany': ['Bavaria', 'Berlin'],
  };
  final Map<String, List<String>> _cities = {
    'California': ['Los Angeles', 'San Francisco', 'San Diego'],
    'Nairobi': ['Nairobi CBD', 'Westlands', 'Karen'],
    'Texas': ['Houston', 'Dallas', 'Austin'],
    'New York': ['New York City', 'Buffalo'],
    'Mombasa': ['Mombasa Island', 'Diani'],
    'Kisumu': ['Kisumu CBD'],
    'England': ['London', 'Manchester', 'Birmingham'],
    'Ontario': ['Toronto', 'Ottawa'],
    'Bavaria': ['Munich', 'Nuremberg'],
    'Berlin': ['Berlin City'],
  };


  void _navigateToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
    setState(() {
      errorMessage = null;
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
      // Save token for future API calls (e.g., using Provider or SharedPreferences)
      // Navigate to the next screen or show success
      // Navigator.pushReplacementNamed(context, '/feed');
      setState(() {
        isSubmitting = false;
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        isSubmitting = false;
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _submitRegister() async {
    setState(() {
      errorMessage = null;
      isSubmitting = false;
    });
    if (!_formKeyRegister.currentState!.validate()) {
      return;
    }
    _formKeyRegister.currentState!.save();
    if (_registerPassword != _registerConfirmPassword) {
      setState(() {
        errorMessage = 'Passwords do not match';
      });
      return;
    }
    setState(() {
      isSubmitting = true;
    });
    try {
      final user = await UserService.register(
        User(
          username: _registerUsername!,
          password: _registerPassword!,
          email: _registerEmail!,
          role: _registerRole!,
          fullName: _registerFullName!,
        ),
      );
      // Registration successful, navigate to login or show success
      // _navigateToPage(0);
      setState(() {
        isSubmitting = false;
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        isSubmitting = false;
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // Helper to show error at the top of the screen (like a banner)
  Widget _buildTopErrorBanner() {
    if (errorMessage == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFF5C7C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              errorMessage!,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
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
            _buildTopErrorBanner(),
            if (errorMessage != null)
              ErrorMessageBox(message: errorMessage!),
            AppTextFormField(
              labelText: 'Email or Username',
              icon: Icons.person_outline,
              onSaved: (v) => _loginUsername = v ?? '',
              validator: (v) => v == null || v.isEmpty ? 'Username required' : null,
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              labelText: 'Password',
              icon: Icons.lock_outline,
              isPassword: true,
              onSaved: (v) => _loginPassword = v ?? '',
              validator: (v) => v == null || v.isEmpty ? 'Password required' : null,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Sign In',
              isLoading: isSubmitting,
              // If isLoading is true, AppButton's internal onPressed will be null.
              // Otherwise, it uses _submitLogin. This line is fine as is.
              onPressed: _submitLogin,
            ),
            const SizedBox(height: 20),
            AppButton(
              text: 'Register',
              // This button is always active, allowing navigation to register.
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopErrorBanner(),
            if (errorMessage != null)
              ErrorMessageBox(message: errorMessage!),
            AppTextFormField(
              labelText: 'Full Name',
              icon: Icons.person_outline,
              onSaved: (v) => _registerFullName = v,
              validator: (v) => v == null || v.isEmpty ? 'Full name required' : null,
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              labelText: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              onSaved: (v) => _registerEmail = v,
              validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null,
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              labelText: 'Username',
              icon: Icons.person_outline,
              onSaved: (v) => _registerUsername = v,
              validator: (v) => v == null || v.isEmpty ? 'Username required' : null,
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              labelText: 'Password',
              icon: Icons.lock_outline,
              isPassword: true,
              onSaved: (v) => _registerPassword = v,
              validator: (v) => v == null || v.length < 6 ? 'Password must be at least 6 characters' : null,
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              labelText: 'Confirm Password',
              icon: Icons.lock_outline,
              isPassword: true,
              onSaved: (v) => _registerConfirmPassword = v,
              validator: (v) => v == null || v.isEmpty ? 'Confirm password' : null,
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              labelText: 'Role',
              icon: Icons.badge_outlined,
              onSaved: (v) => _registerRole = v,
              validator: (v) => v == null || v.isEmpty ? 'Role required' : null,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Sign Up',
              isLoading: isSubmitting,
              onPressed: _submitRegister,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already have an account?'),
                TextButton(
                  onPressed: () => _navigateToPage(0),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(color: Colors.blueAccent),
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
        title: const Text('Celebrating'),
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
            Center(
              child: Text(
                'Sign Up for an Account',
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