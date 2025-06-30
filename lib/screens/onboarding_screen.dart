// onboarding_screen.dart

import 'package:flutter/material.dart';
// Assuming you have these custom widgets in your project
import '../widgets/app_buttons.dart';
import '../widgets/app_dropdown.dart';
import '../widgets/app_text_fields.dart';
import '../widgets/error_message.dart';
import '../services/onboarding_service.dart';
import '../models/onboarding_data.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {

  final _formKeyOnboarding = GlobalKey<FormState>();

  String? _onboardingFirstName;
  String? _onboardingLastName;
  String? _onboardingSex;
  String? _onboardingDay;
  String? _onboardingMonth;
  String? _onboardingYear;
  String? _onboardingPhoneNumber;
  String? _onboardingEmail;
  String? _onboardingUsername;
  String? _onboardingPassword;
  String? _onboardingConfirmPassword;
  String? _onboardingCountry;
  String? _onboardingState;
  String? _onboardingCity;


  String? errorMessage; // For general/backend errors
  bool isSubmitting = false;

  // --- Dropdown Data ---
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


  // The submit function for the onboarding form
  void _submitOnboardingForm() async {
    Navigator.pushReplacementNamed(context, '/feed');
    setState(() {
      errorMessage = null;
      isSubmitting = false;
    });
    // 1. Validate the form first
    if (!_formKeyOnboarding.currentState!.validate()) {
      return; // Stop if validation fails
    }

    _formKeyOnboarding.currentState!.save();

    // 2. Basic password confirmation check
    if (_onboardingPassword != _onboardingConfirmPassword) {
      setState(() {
        errorMessage = 'Passwords do not match';
      });
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      // Format birth date as yyyy-MM-dd
      final monthIndex = _months.indexOf(_onboardingMonth!) + 1;
      final birthDate = '${_onboardingYear!}-${monthIndex.toString().padLeft(2, '0')}-${_onboardingDay!.padLeft(2, '0')}';
      final data = OnboardingData(
        firstName: _onboardingFirstName!,
        lastName: _onboardingLastName!,
        sex: _onboardingSex!,
        birthDate: birthDate,
        phoneNumber: _onboardingPhoneNumber,
        email: _onboardingEmail!,
        username: _onboardingUsername!,
        password: _onboardingPassword!,
        country: _onboardingCountry!,
        state: _onboardingState!,
        city: _onboardingCity!,
      );
      await OnboardingService.submitOnboarding(data);
      // Navigate or show success
      print("Onboarding successful!");
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

  // The build method for the onboarding form content
  Widget _buildOnboardingFormContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKeyOnboarding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopErrorBanner(),
            Center(
              child: Text(
                'Complete Your Profile',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),

            if (errorMessage != null)
              ErrorMessageBox(message: errorMessage!),
            AppTextFormField(
              labelText: 'First Name',
              icon: Icons.person_outline,
              onSaved: (v) => _onboardingFirstName = v,
              validator: (v) => v == null || v.isEmpty ? 'First name is required' : null,
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              labelText: 'Last Name',
              icon: Icons.person_outline,
              onSaved: (v) => _onboardingLastName = v,
              validator: (v) => v == null || v.isEmpty ? 'Last name is required' : null,
            ),
            const SizedBox(height: 16),
            AppDropdownFormField<String>(
              labelText: 'Select Sex',
              icon: Icons.transgender,
              value: _onboardingSex,
              items: _sexOptions.map((String sex) {
                return DropdownMenuItem<String>(
                  value: sex,
                  child: Text(sex, overflow: TextOverflow.ellipsis, softWrap: false),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _onboardingSex = newValue;
                });
              },
              onSaved: (newValue) => _onboardingSex = newValue,
              validator: (value) => value == null ? 'Please select your sex' : null,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text('Birth Date', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ),
            Row(
              children: [
                Expanded(
                  child: AppDropdownFormField<String>(
                    labelText: 'Month',
                    icon: Icons.calendar_today_outlined,
                    value: _onboardingMonth,
                    items: _months.map((String month) {
                      return DropdownMenuItem<String>(
                        value: month,
                        child: Text(month, overflow: TextOverflow.ellipsis, softWrap: false),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _onboardingMonth = newValue;
                      });
                    },
                    onSaved: (newValue) => _onboardingMonth = newValue,
                    validator: (value) => value == null ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppDropdownFormField<String>(
                    labelText: 'Day',
                    icon: Icons.calendar_today_outlined,
                    value: _onboardingDay,
                    items: _days.map((String day) {
                      return DropdownMenuItem<String>(
                        value: day,
                        child: Text(day, overflow: TextOverflow.ellipsis, softWrap: false),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _onboardingDay = newValue;
                      });
                    },
                    onSaved: (newValue) => _onboardingDay = newValue,
                    validator: (value) => value == null ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppDropdownFormField<String>(
                    labelText: 'Year',
                    icon: Icons.calendar_today_outlined,
                    value: _onboardingYear,
                    items: _years.map((String year) {
                      return DropdownMenuItem<String>(
                        value: year,
                        child: Text(year, overflow: TextOverflow.ellipsis, softWrap: false),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _onboardingYear = newValue;
                      });
                    },
                    onSaved: (newValue) => _onboardingYear = newValue,
                    validator: (value) => value == null ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              labelText: 'Phone Number (Optional)',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              onSaved: (v) => _onboardingPhoneNumber = v,
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              labelText: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              onSaved: (v) => _onboardingEmail = v,
              validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null,
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              labelText: 'Username',
              icon: Icons.person_outline,
              onSaved: (v) => _onboardingUsername = v,
              validator: (v) => v == null || v.isEmpty ? 'Username is required' : null,
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              labelText: 'Password',
              icon: Icons.lock_outline,
              isPassword: true,
              onSaved: (v) => _onboardingPassword = v,
              validator: (v) => v == null || v.length < 6 ? 'Password must be at least 6 characters' : null,
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              labelText: 'Confirm Password',
              icon: Icons.lock_outline,
              isPassword: true,
              onSaved: (v) => _onboardingConfirmPassword = v,
              validator: (v) => v == null || v.isEmpty ? 'Confirm password is required' : null,
            ),
            const SizedBox(height: 16),
            AppDropdownFormField<String>(
              labelText: 'Select Country',
              icon: Icons.public_outlined,
              value: _onboardingCountry,
              items: _countries.map((String country) {
                return DropdownMenuItem<String>(
                  value: country,
                  child: Text(country, overflow: TextOverflow.ellipsis, softWrap: false),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _onboardingCountry = newValue;
                  _onboardingState = null;
                  _onboardingCity = null;
                });
              },
              onSaved: (newValue) => _onboardingCountry = newValue,
              validator: (value) => value == null ? 'Please select a country' : null,
            ),
            const SizedBox(height: 16),
            AppDropdownFormField<String>(
              labelText: 'Select State',
              icon: Icons.location_on_outlined,
              value: _onboardingState,
              items: (_states[_onboardingCountry] ?? []).map((String state) {
                return DropdownMenuItem<String>(
                  value: state,
                  child: Text(state, overflow: TextOverflow.ellipsis, softWrap: false),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _onboardingState = newValue;
                  _onboardingCity = null;
                });
              },
              onSaved: (newValue) => _onboardingState = newValue,
              validator: (value) => value == null ? 'Please select a state' : null,
            ),
            const SizedBox(height: 16),
            AppDropdownFormField<String>(
              labelText: 'Select City',
              icon: Icons.location_city_outlined,
              value: _onboardingCity,
              items: (_cities[_onboardingState] ?? []).map((String city) {
                return DropdownMenuItem<String>(
                  value: city,
                  child: Text(city, overflow: TextOverflow.ellipsis, softWrap: false),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _onboardingCity = newValue;
                });
              },
              onSaved: (newValue) => _onboardingCity = newValue,
              validator: (value) => value == null ? 'Please select a city' : null,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Complete Onboarding',
              isLoading: isSubmitting,
              onPressed: _submitOnboardingForm,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // Directly use the _buildOnboardingFormContent as the child
        child: _buildOnboardingFormContent(),
      ),
    );
  }
}