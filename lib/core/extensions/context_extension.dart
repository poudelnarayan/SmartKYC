import 'package:flutter/material.dart';
import 'package:smartkyc/l10n/app_localizations.dart';

extension BuildContextExtensions on BuildContext {
  // Theme Extensions
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;

  // Media Query Extensions
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenHeight => mediaQuery.size.height;
  double get screenWidth => mediaQuery.size.width;
  EdgeInsets get padding => mediaQuery.padding;
  EdgeInsets get viewInsets => mediaQuery.viewInsets;
  Brightness get platformBrightness => mediaQuery.platformBrightness;

  // Localization Extensions
  AppLocalizations get l10n => AppLocalizations.of(this);
  bool get isRTL => Directionality.of(this) == TextDirection.rtl;

  // Navigation Extensions
  void pop<T>([T? result]) => Navigator.of(this).pop(result);
  Future<T?> push<T>(Widget page) => Navigator.of(this).push<T>(
        MaterialPageRoute(builder: (context) => page),
      );

  // Snackbar Extensions
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
