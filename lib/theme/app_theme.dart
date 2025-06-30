import 'package:flutter/material.dart';

class AppTheme {
  static const Color appYellow = Color(0xFFFCD535);
  static const Color appDark = Color(0xFF181A20);
  static const Color appSurfaceDark = Color(0xFF23262F);
  static const Color appLight = Color(0xFFFFFFFF);
  static const Color appSurfaceLight = Color(0xFFF5F5F5);

  static ThemeData lightTheme = ThemeData(
    colorScheme: const ColorScheme.light(
      primary: appYellow,
      secondary: appDark,
      background: appLight,
      surface: appSurfaceLight,
      onPrimary: appDark,
    ),
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(
      backgroundColor: appYellow,
      foregroundColor: appDark,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    colorScheme: const ColorScheme.dark(
      primary: appYellow,
      secondary: appLight,
      background: appDark,
      surface: appSurfaceDark,
      onPrimary: appLight,
    ),
    brightness: Brightness.dark,
    appBarTheme: const AppBarTheme(
      backgroundColor: appDark,
      foregroundColor: appYellow,
    ),
  );
}
