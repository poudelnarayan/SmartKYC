import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lottie/lottie.dart';
import 'package:smartkyc/features/verification_steps/presentation/pages/verification_steps_page.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});
  static const pageName = "/verifyEmail";

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool _isSendingEmail = false;
  bool _isCheckingVerification = false;
  final _auth = FirebaseAuth.instance;

  Future<void> _sendVerificationEmail() async {
    if (_isSendingEmail) return;

    setState(() {
      _isSendingEmail = true;
    });

    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send verification email: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSendingEmail = false;
        });
      }
    }
  }

  Future<void> _checkEmailVerification() async {
    if (_isCheckingVerification) return;

    setState(() {
      _isCheckingVerification = true;
    });

    try {
      await _auth.currentUser?.reload();
      final user = _auth.currentUser;

      if (user?.emailVerified ?? false) {
        if (mounted) {
          context.go(VerificationStepsPage.pageName);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email not verified yet. Please check your email.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking verification: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingVerification = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final user = _auth.currentUser;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Lottie.network(
                    'https://lottie.host/2e26cc42-0d81-49c5-ac2c-aa6e1f64ea71/UyXPnDwXAj.json',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.mark_email_unread_outlined,
                        size: 80,
                        color: Colors.white,
                      );
                    },
                  ),
                ).animate().scale(),
                const SizedBox(height: 32),
                Text(
                  l10n.verifyEmail,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn().slideY(),
                const SizedBox(height: 16),
                Text(
                  l10n
                      .verifyEmailDesc(user?.email as String)
                      .replaceAll('{email}', user?.email ?? ''),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn().slideY(),
                const SizedBox(height: 48),
                FilledButton.icon(
                  onPressed:
                      _isCheckingVerification ? null : _checkEmailVerification,
                  icon: _isCheckingVerification
                      ? Container(
                          width: 24,
                          height: 24,
                          padding: const EdgeInsets.all(2),
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(
                    _isCheckingVerification ? l10n.checking : l10n.verifyNow,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: theme.colorScheme.primary,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ).animate().fadeIn().scale(),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _isSendingEmail ? null : _sendVerificationEmail,
                  icon: _isSendingEmail
                      ? Container(
                          width: 20,
                          height: 20,
                          padding: const EdgeInsets.all(2),
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.email_outlined),
                  label: Text(
                    _isSendingEmail ? l10n.sending : l10n.resendEmail,
                    style: const TextStyle(color: Colors.white),
                  ),
                ).animate().fadeIn(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
