import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;
  Locale? locale;

  void toggleTheme() {
    themeMode = themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setLocale(Locale newLocale) {
    locale = newLocale;
    notifyListeners();
  }
}
