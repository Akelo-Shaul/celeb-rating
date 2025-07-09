// onboarding_screen.dart

import 'package:celebrating/utils/route.dart';
import 'package:flutter/material.dart';
import 'package:celebrating/l10n/app_localizations.dart';
// Assuming you have these custom widgets in your project
import '../widgets/app_buttons.dart';
import '../widgets/app_dropdown.dart';
import '../widgets/app_text_fields.dart';
import '../widgets/error_message.dart';
import '../services/onboarding_service.dart';
import '../models/onboarding_data.dart';
import '../widgets/parted_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentIndex = 0;

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
                AppLocalizations.of(context)!.completeYourProfile,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),

            if (errorMessage != null)
              ErrorMessageBox(message: errorMessage!),
            AppTextFormField(
              labelText: AppLocalizations.of(context)!.firstName,
              icon: Icons.person_outline,
              onSaved: (v) => _onboardingFirstName = v,
              validator: (v) => v == null || v.isEmpty ? AppLocalizations.of(context)!.firstNameRequired : null,
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              labelText: AppLocalizations.of(context)!.lastName,
              icon: Icons.person_outline,
              onSaved: (v) => _onboardingLastName = v,
              validator: (v) => v == null || v.isEmpty ? AppLocalizations.of(context)!.lastNameRequired : null,
            ),
            const SizedBox(height: 16),
            AppDropdownFormField<String>(
              labelText: AppLocalizations.of(context)!.selectSex,
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
              validator: (value) => value == null ? AppLocalizations.of(context)!.pleaseSelectSex : null,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(AppLocalizations.of(context)!.birthDate, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ),
            Row(
              children: [
                Expanded(
                  child: AppDropdownFormField<String>(
                    labelText: AppLocalizations.of(context)!.month,
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
                    validator: (value) => value == null ? AppLocalizations.of(context)!.req : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppDropdownFormField<String>(
                    labelText: AppLocalizations.of(context)!.day,
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
                    validator: (value) => value == null ? AppLocalizations.of(context)!.req : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppDropdownFormField<String>(
                    labelText: AppLocalizations.of(context)!.year,
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
                    validator: (value) => value == null ? AppLocalizations.of(context)!.req : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              labelText: AppLocalizations.of(context)!.phoneNumberOptional,
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              onSaved: (v) => _onboardingPhoneNumber = v,
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              labelText: AppLocalizations.of(context)!.email,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              onSaved: (v) => _onboardingEmail = v,
              validator: (v) => v == null || !v.contains('@') ? AppLocalizations.of(context)!.enterValidEmail : null,
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              labelText: AppLocalizations.of(context)!.username,
              icon: Icons.person_outline,
              onSaved: (v) => _onboardingUsername = v,
              validator: (v) => v == null || v.isEmpty ? AppLocalizations.of(context)!.usernameRequired : null,
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              labelText: AppLocalizations.of(context)!.password,
              icon: Icons.lock_outline,
              isPassword: true,
              onSaved: (v) => _onboardingPassword = v,
              validator: (v) => v == null || v.length < 6 ? AppLocalizations.of(context)!.passwordMinLength : null,
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              labelText: AppLocalizations.of(context)!.confirmPassword,
              icon: Icons.lock_outline,
              isPassword: true,
              onSaved: (v) => _onboardingConfirmPassword = v,
              validator: (v) => v == null || v.isEmpty ? AppLocalizations.of(context)!.confirmPasswordRequired : null,
            ),
            const SizedBox(height: 16),
            AppDropdownFormField<String>(
              labelText: AppLocalizations.of(context)!.selectCountry,
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
              validator: (value) => value == null ? AppLocalizations.of(context)!.pleaseSelectCountry : null,
            ),
            const SizedBox(height: 16),
            AppDropdownFormField<String>(
              labelText: AppLocalizations.of(context)!.selectState,
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
              validator: (value) => value == null ? AppLocalizations.of(context)!.pleaseSelectState : null,
            ),
            const SizedBox(height: 16),
            AppDropdownFormField<String>(
              labelText: AppLocalizations.of(context)!.selectCity,
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
              validator: (value) => value == null ? AppLocalizations.of(context)!.pleaseSelectCity : null,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: AppLocalizations.of(context)!.completeOnboarding,
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
  void initState() {
    super.initState();
    if (_currentIndex == 0) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _currentIndex == 0) {
          setState(() {
            _currentIndex = 1;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFFD6AF0C);
    final textColorLight = isDark ? Colors.grey[700]! : Colors.grey[300]!;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Show the correct tab based on _currentIndex
            if (_currentIndex == 0)
              _onboardingStart(),
            if (_currentIndex == 1)
              _verifyOTP(),
            if (_currentIndex == 2)
              _countrySelect(),
            if (_currentIndex == 3)
              _selectAccountType(),
            PositionedDirectional(
              bottom: 0,
              start: 0,
              end: 0,
              child: Container(
                padding: const EdgeInsetsDirectional.only(start: 30, end: 30, bottom: 30),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return _currentIndex == index
                        ? Container(
                            margin: const EdgeInsetsDirectional.all(10),
                            padding: const EdgeInsetsDirectional.all(10),
                            height: 10,
                            width: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: primaryColor,
                              border: Border.all(color: primaryColor),
                            ),
                          )
                        : Container(
                            margin: const EdgeInsetsDirectional.all(10),
                            padding: const EdgeInsetsDirectional.all(10),
                            height: 10,
                            width: 20,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: textColorLight,
                              border: Border.all(color: textColorLight),
                            ),
                          );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _onboardingStart() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7FA),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.thankYouForSigningUp,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFFD6AF0C),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              AppLocalizations.of(context)!.thankYouForRegistering,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF222222),
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _verifyOTP() {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onBackground;
    final secondaryTextColor = theme.textTheme.bodyMedium?.color ?? textColor;
    final accentColor = theme.colorScheme.primary;
    final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
    final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());

    // Helper to move focus automatically
    void _onChanged(String value, int index) {
      if (value.length == 1 && index < 3) {
        _focusNodes[index + 1].requestFocus();
      }
      if (value.isEmpty && index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalizations.of(context)!.enterVerificationCode,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.codeSentTo(_onboardingEmail ?? ''),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: secondaryTextColor,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              return Container(
                width: 56,
                height: 56,
                margin: EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _focusNodes[index].hasFocus
                        ? accentColor
                        : theme.dividerColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      counterText: '',
                    ),
                    onChanged: (value) => _onChanged(value, index),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20, ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: AppButton(text: AppLocalizations.of(context)!.verify, onPressed: (){
              // Navigate to next tab (account type selection)
              setState(() {
                _currentIndex = 2;
              });
            }),
          ),
          const SizedBox(height: 10, ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppLocalizations.of(context)!.didNotReceiveEmail, style: theme.textTheme.bodyMedium?.copyWith(color: secondaryTextColor)),
              TextButton(
                onPressed: () => {},
                child: Text(
                  AppLocalizations.of(context)!.resendOtp,
                  style: theme.textTheme.bodyMedium?.copyWith(color: accentColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _selectAccountType() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7FA),
          borderRadius: BorderRadius.circular(18),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.chooseAccountType,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFD6AF0C),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Color(0xFFD6AF0C), width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.member,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Color(0xFFD6AF0C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.memberDescription,
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF222222),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Color(0xFFD6AF0C), width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.celebrityStatus,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Color(0xFFD6AF0C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.celebrityDescription,
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF222222),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              AppOutlinedButton(
                text: AppLocalizations.of(context)!.continueAsMember,
                textColor: Color(0xFFD6AF0C),
                onPressed: () {
                  //TODO: Navigate to profile
                  Navigator.pushReplacementNamed(context, feedScreen);
                  setState(() {
                  });
                },
              ),
              const SizedBox(height: 14),
              PartedButton(
                onPressed: () {
                  // Switch to country/state selection tab
                  Navigator.pushReplacementNamed(context, verificationScreen);
                  setState(() {
                  });
                },
                leftText: AppLocalizations.of(context)!.continueAs,
                rightText: AppLocalizations.of(context)!.celebrity,
                leftTextColor: Color(0xFFD6AF0C),
                rightTextColor: Colors.white,
                leftBackgroundColor: Colors.white,
                rightBackgroundColor: Color(0xFFD6AF0C),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _countrySelect() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
            'assets/images/celebratinglogo.png',
            width: MediaQuery.of(context).size.width * 0.8
        ),
        AppDropdownFormField<String>(
          labelText: AppLocalizations.of(context)!.selectCountry,
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
            });
          },
          onSaved: (newValue) => _onboardingCountry = newValue,
          validator: (value) => value == null ? AppLocalizations.of(context)!.pleaseSelectCountry : null,
        ),
        const SizedBox(height: 16),
        AppDropdownFormField<String>(
          labelText: AppLocalizations.of(context)!.selectState,
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
            });
          },
          onSaved: (newValue) => _onboardingState = newValue,
          validator: (value) => value == null ? AppLocalizations.of(context)!.pleaseSelectState : null,
        ),
        const SizedBox(height: 50,),
        AppButton(text: AppLocalizations.of(context)!.continueText, onPressed: (){
          setState(() {
            _currentIndex = 3;
          });
        })
      ],
    );
  }


}

class CelebrityLeftClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width - 8, 0);
    path.quadraticBezierTo(size.width, size.height / 2, size.width - 8, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class CelebrityCurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final path = Path();
    path.moveTo(8, 0);
    path.quadraticBezierTo(size.width, size.height / 2, 8, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}