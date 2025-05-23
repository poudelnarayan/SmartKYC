import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:smartkyc/core/theme/app_color_scheme.dart';
import 'package:smartkyc/l10n/app_localizations.dart';
import 'package:smartkyc/features/auth/presentation/pages/singin_page.dart';

class SignUpSuccessPage extends StatelessWidget {
  final String email;

  static const pageName = "/signupSuccess";

  const SignUpSuccessPage({
    super.key,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColorScheme.getGradientColors(isDark),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success animation
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: (isDark ? AppColorScheme.darkText : Colors.white)
                        .withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Lottie.asset(
                    'assets/lottie/checkmark.json',
                    repeat: false,
                  ),
                ).animate().scale(),

                const SizedBox(height: 40),

                // Success message
                Text(
                  l10n.signUpSuccessTitle,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColorScheme.darkText : Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn().slideY(),

                const SizedBox(height: 16),

                Text(
                  l10n.signUpSuccessMessage,
                  style: TextStyle(
                    fontSize: 16,
                    color: (isDark ? AppColorScheme.darkText : Colors.white)
                        .withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn().slideY(),

                const SizedBox(height: 8),

                Text(
                  email,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColorScheme.darkText : Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn().slideY(),

                const SizedBox(height: 48),

                // Continue to sign in button
                FilledButton.icon(
                  onPressed: () => context.go(SigninPage.pageName),
                  icon: const Icon(Icons.login_rounded),
                  label: Text(
                    l10n.continueToSignIn,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        isDark ? AppColorScheme.darkText : Colors.white,
                    foregroundColor: theme.colorScheme.primary,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ).animate().fadeIn().scale(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
