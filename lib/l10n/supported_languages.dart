import 'package:flutter/material.dart';

class SupportedLanguage {
  final String code;
  final String label;
  final String flag;

  SupportedLanguage(this.code, this.label, this.flag);
}

final supportedLanguages = [
  SupportedLanguage('en', 'English', '🇬🇧'),
  SupportedLanguage('sw', 'Kiswahili', '🇰🇪'),
];
