import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smartkyc/core/theme/app_color_scheme.dart';

import '../../../../core/services/biometric_services.dart';

class BiometricPromptDialog extends StatelessWidget {
  final String email;
  final String password;

  const BiometricPromptDialog({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColorScheme.getCardBackground(isDark),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColorScheme.getCardBorder(isDark),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColorScheme.darkPrimary.withOpacity(0.1)
                    : AppColorScheme.lightPrimary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.fingerprint,
                size: 48,
                color: isDark
                    ? AppColorScheme.darkPrimary
                    : AppColorScheme.lightPrimary,
              ),
            ).animate().scale(),
            const SizedBox(height: 24),
            Text(
              'Enable Biometric Login?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color:
                    isDark ? AppColorScheme.darkText : AppColorScheme.lightText,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn().slideY(),
            const SizedBox(height: 8),
            Text(
              'Would you like to use your fingerprint or face ID for faster login next time?',
              style: TextStyle(
                color: isDark
                    ? AppColorScheme.darkTextSecondary
                    : AppColorScheme.lightTextSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn().slideY(),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                        color: isDark
                            ? AppColorScheme.darkCardBorder
                            : AppColorScheme.lightCardBorder,
                      ),
                    ),
                    child: Text(
                      'Not Now',
                      style: TextStyle(
                        color: isDark
                            ? AppColorScheme.darkText
                            : AppColorScheme.lightText,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      await BiometricService.saveBiometricCredentials(
                        email: email,
                        password: password,
                      );
                      if (context.mounted) {
                        Navigator.pop(context, true);
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColorScheme.darkPrimary
                          : AppColorScheme.lightPrimary,
                      foregroundColor:
                          isDark ? AppColorScheme.darkSurface : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Enable'),
                  ),
                ),
              ],
            ).animate().fadeIn().slideY(),
          ],
        ),
      ),
    );
  }
}
