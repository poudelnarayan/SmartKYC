import 'package:flutter/material.dart';

class AppColorScheme {
  // Light Theme Colors
  static const Color lightPrimary = Color(0xFF1A73E8);
  static const Color lightSecondary = Color(0xFF5F6368);
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Colors.white;
  static const Color lightText = Color(0xFF202124);
  static const Color lightTextSecondary = Color(0xFF5F6368);
  static const Color lightCardBorder = Color(0xFFE8EAED);

  // Dark Theme Colors
  static const Color darkPrimary = Color(0xFF8AB4F8);
  static const Color darkSecondary = Color(0xFFBDC1C6);
  static const Color darkBackground = Color(0xFF202124);
  static const Color darkSurface = Color(0xFF303134);
  static const Color darkText = Color(0xFFE8EAED);
  static const Color darkTextSecondary = Color(0xFFBDC1C6);
  static const Color darkCardBorder = Color(0xFF3C4043);

  // Status Colors
  static const Color success = Color(0xFF34A853);
  static const Color error = Color(0xFFEA4335);
  static const Color warning = Color(0xFFFBBC04);
  static const Color info = Color(0xFF4285F4);

  // Gradient Colors - Light Theme
  static const lightGradientStart = Color(0xFF2563EB); // Primary Blue
  static const lightGradientEnd = Color(0xFF3B82F6); // Secondary Blue

  // Gradient Colors - Dark Theme
  static const darkGradientStart = Color(0xFF1E3A8A); // Dark Blue
  static const darkGradientEnd = Color(0xFF1F2937); // Dark Gray Blue

  // Get gradient colors based on theme mode
  static List<Color> getGradientColors(bool isDark) {
    return isDark
        ? [darkGradientStart, darkGradientEnd]
        : [lightGradientStart, lightGradientEnd];
  }

  // Helper methods
  static Color getCardBackground(bool isDark) {
    return isDark ? darkSurface : lightSurface;
  }

  static Color getCardBorder(bool isDark) {
    return isDark ? darkCardBorder : lightCardBorder;
  }
}
