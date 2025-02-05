import 'package:flutter/material.dart';

class AppColorScheme {
  // Light Theme Colors
  static const lightPrimary = Color(0xFF2563EB); // Blue
  static const lightSecondary = Color(0xFF3B82F6); // Lighter Blue
  static const lightBackground = Color(0xFFF8FAFC); // Very Light Gray
  static const lightSurface = Color(0xFFFFFFFF); // White
  static const lightError = Color(0xFFDC2626); // Red
  static const lightText = Color(0xFF1F2937); // Dark Gray
  static const lightTextSecondary = Color(0xFF6B7280); // Medium Gray

  // Dark Theme Colors
  static const darkPrimary = Color(0xFF3B82F6); // Blue
  static const darkSecondary = Color(0xFF60A5FA); // Lighter Blue
  static const darkBackground = Color(0xFF1F2937); // Dark Blue Gray
  static const darkSurface = Color(0xFF111827); // Darker Blue Gray
  static const darkError = Color(0xFFEF4444); // Red
  static const darkText = Color(0xFFF9FAFB); // Off White
  static const darkTextSecondary = Color(0xFFD1D5DB); // Light Gray

  // Gradient Colors - Light Theme
  static const lightGradientStart = Color(0xFF2563EB); // Primary Blue
  static const lightGradientEnd = Color(0xFF3B82F6); // Secondary Blue

  // Gradient Colors - Dark Theme
  static const darkGradientStart = Color(0xFF1E3A8A); // Dark Blue
  static const darkGradientEnd = Color(0xFF1F2937); // Dark Gray Blue

  // Common Colors
  static const success = Color(0xFF22C55E); // Green
  static const warning = Color(0xFFF59E0B); // Orange
  static const info = Color(0xFF3B82F6); // Blue

  // Card Colors - Light Theme
  static const lightCardBackground = Color(0xFFFFFFFF);
  static const lightCardBorder = Color(0xFFE5E7EB);

  // Card Colors - Dark Theme
  static const darkCardBackground = Color(0xFF1F2937);
  static const darkCardBorder = Color(0xFF374151);

  // Get gradient colors based on theme mode
  static List<Color> getGradientColors(bool isDark) {
    return isDark
        ? [darkGradientStart, darkGradientEnd]
        : [lightGradientStart, lightGradientEnd];
  }

  // Get card colors based on theme mode
  static Color getCardBackground(bool isDark) {
    return isDark ? darkCardBackground : lightCardBackground;
  }

  static Color getCardBorder(bool isDark) {
    return isDark ? darkCardBorder : lightCardBorder;
  }
}
