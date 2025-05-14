// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'app_color_scheme.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColorScheme.lightPrimary,
        secondary: AppColorScheme.lightSecondary,
        background: AppColorScheme.lightBackground,
        surface: AppColorScheme.lightSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: AppColorScheme.lightText,
        onSurface: AppColorScheme.lightText,
      ),
      scaffoldBackgroundColor: AppColorScheme.lightBackground,
      cardColor: AppColorScheme.lightSurface,
      dialogBackgroundColor: AppColorScheme.lightSurface,

      // Text Theme
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: AppColorScheme.lightText,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: AppColorScheme.lightText,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: AppColorScheme.lightText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: AppColorScheme.lightText,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: AppColorScheme.lightTextSecondary,
          fontSize: 14,
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorScheme.lightPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColorScheme.lightPrimary,
          side: BorderSide(color: AppColorScheme.lightPrimary),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColorScheme.lightPrimary,
          minimumSize: const Size(88, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorScheme.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColorScheme.lightCardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColorScheme.lightCardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColorScheme.lightPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColorScheme.error),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: AppColorScheme.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColorScheme.lightCardBorder),
        ),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColorScheme.darkPrimary,
        secondary: AppColorScheme.darkSecondary,
        background: AppColorScheme.darkBackground,
        surface: AppColorScheme.darkSurface,
        onPrimary: AppColorScheme.darkSurface,
        onSecondary: AppColorScheme.darkSurface,
        onBackground: AppColorScheme.darkText,
        onSurface: AppColorScheme.darkText,
      ),
      scaffoldBackgroundColor: AppColorScheme.darkBackground,
      cardColor: AppColorScheme.darkSurface,
      dialogBackgroundColor: AppColorScheme.darkSurface,

      // Text Theme
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: AppColorScheme.darkText,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: AppColorScheme.darkText,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: AppColorScheme.darkText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: AppColorScheme.darkText,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: AppColorScheme.darkTextSecondary,
          fontSize: 14,
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorScheme.darkPrimary,
          foregroundColor: AppColorScheme.darkSurface,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColorScheme.darkPrimary,
          side: BorderSide(color: AppColorScheme.darkPrimary),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColorScheme.darkPrimary,
          minimumSize: const Size(88, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorScheme.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColorScheme.darkCardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColorScheme.darkCardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColorScheme.darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColorScheme.error),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: AppColorScheme.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColorScheme.darkCardBorder),
        ),
      ),
    );
  }
}
