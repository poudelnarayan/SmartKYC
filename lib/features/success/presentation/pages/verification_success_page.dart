import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smartkyc/l10n/app_localizations.dart';
import 'package:smartkyc/features/user_profile/presentation/pages/user_profile_page.dart';

class VerificationSuccessPage extends StatefulWidget {
  const VerificationSuccessPage({super.key});

  static const pageName = "/verificationSuccess";

  @override
  State<VerificationSuccessPage> createState() =>
      _VerificationSuccessPageState();
}

class _VerificationSuccessPageState extends State<VerificationSuccessPage> {
  static const int _countdownDuration = 5;
  late Timer _timer;
  int _timeLeft = _countdownDuration;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 1) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _timer.cancel();
        if (mounted) {
          context.go(UserProfilePage.pageName);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Colors.grey[900]!,
                    Colors.grey[850]!,
                  ]
                : [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Countdown timer
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'Redirecting in $_timeLeft',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ).animate().fadeIn().scale(),
                  SizedBox(
                    width: 10,
                  ),
                ],
              ),
              const SizedBox(height: 48),
              // Success animation with error handling
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Lottie.asset(
                  'assets/lottie/verification_success.json',
                  width: 200,
                  height: 200,
                  repeat: true,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? Colors.grey[800]
                            : Colors.white.withOpacity(0.9),
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green[400],
                        size: 100,
                      ),
                    );
                  },
                  frameBuilder: (context, child, composition) {
                    if (composition == null) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: isDark ? Colors.grey[300] : Colors.white,
                        ),
                      );
                    }
                    return child;
                  },
                ),
              ).animate().scale(),
              const SizedBox(height: 48),
              // Success text
              Text(
                l10n.verificationSuccessTitle,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn().slideY(),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  l10n.verificationSuccessMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark
                        ? Colors.grey[300]
                        : Colors.white.withOpacity(0.9),
                    height: 1.5,
                  ),
                ),
              ).animate().fadeIn().slideY(),
              const SizedBox(height: 64),
              // Continue button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: FilledButton.icon(
                  onPressed: () => context.go(UserProfilePage.pageName),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: isDark
                        ? Colors.grey[900]
                        : Theme.of(context).colorScheme.primary,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(
                    l10n.continue_operation,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ).animate().fadeIn().scale(),
            ],
          ),
        ),
      ),
    );
  }
}
