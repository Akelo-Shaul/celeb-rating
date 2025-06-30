import 'package:flutter/material.dart';

class SupportedLanguage {
  final String code;
  final String label;
  final String flag;

  SupportedLanguage(this.code, this.label, this.flag);
}

final supportedLanguages = [
  SupportedLanguage('en', 'English', '🇬🇧'),
  SupportedLanguage('es', 'Español', '🇪🇸'),
  SupportedLanguage('fr', 'Français', '🇫🇷'),
  SupportedLanguage('de', 'Deutsch', '🇩🇪'),
  SupportedLanguage('it', 'Italiano', '🇮🇹'),
  SupportedLanguage('sw', 'Kiswahili', '🇰🇪'),
  SupportedLanguage('ar', 'العربية', '🇸🇦'),
];
