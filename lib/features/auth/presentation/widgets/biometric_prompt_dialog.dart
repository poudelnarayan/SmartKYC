import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smartkyc/core/theme/app_color_scheme.dart';
import '../../../../core/services/biometric_services.dart';

class BiometricPromptDialog extends StatefulWidget {
  final String email;
  final String password;
  final bool isfirstTimeSignin;

  const BiometricPromptDialog({
    super.key,
    required this.email,
    required this.password,
    this.isfirstTimeSignin = false,
  });

  @override
  State<BiometricPromptDialog> createState() => _BiometricPromptDialogState();
}

class _BiometricPromptDialogState extends State<BiometricPromptDialog> {
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isVerifying = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _verifyAndEnableBiometrics() async {
    if (_passwordController.text.isEmpty && widget.isfirstTimeSignin == false) {
      setState(() => _errorMessage = 'Please enter your password');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      if (widget.isfirstTimeSignin == false) {
        // Re-authenticate user with password
        final credential = EmailAuthProvider.credential(
          email: widget.email,
          password: _passwordController.text,
        );
        await FirebaseAuth.instance.currentUser!
            .reauthenticateWithCredential(credential);
      }

      // If re-authentication successful, save biometric credentials
      await BiometricService.saveBiometricCredentials(
        email: widget.email,
        password: widget.isfirstTimeSignin
            ? widget.password
            : _passwordController.text,
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = switch (e.code) {
          'credentials is incorrect' => 'Incorrect password',
          'too-many-requests' => 'Too many attempts. Try again later',
          _ => 'Authentication failed',
        };
      });
    } catch (e) {
      setState(() => _errorMessage = 'An error occurred');
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

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
            if (widget.isfirstTimeSignin)
              Text(
                widget.isfirstTimeSignin
                    ? 'Would you like to use your fingerprint or face ID for faster login next time?'
                    : 'Enter your password to enable fingerprint or face ID login',
                style: TextStyle(
                  color: isDark
                      ? AppColorScheme.darkTextSecondary
                      : AppColorScheme.lightTextSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn().slideY(),
            const SizedBox(height: 24),
            if (!widget.isfirstTimeSignin)
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                enabled: !_isVerifying,
                style: TextStyle(
                  color: isDark
                      ? AppColorScheme.darkText
                      : AppColorScheme.lightText,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(
                    color: isDark
                        ? AppColorScheme.darkTextSecondary
                        : AppColorScheme.lightTextSecondary,
                  ),
                  errorText: _errorMessage,
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: _errorMessage != null
                        ? AppColorScheme.error
                        : isDark
                            ? AppColorScheme.darkTextSecondary
                            : AppColorScheme.lightTextSecondary,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: _errorMessage != null
                          ? AppColorScheme.error
                          : isDark
                              ? AppColorScheme.darkTextSecondary
                              : AppColorScheme.lightTextSecondary,
                    ),
                    onPressed: () {
                      setState(() => _isPasswordVisible = !_isPasswordVisible);
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark
                          ? AppColorScheme.darkCardBorder
                          : AppColorScheme.lightCardBorder,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark
                          ? AppColorScheme.darkCardBorder
                          : AppColorScheme.lightCardBorder,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark
                          ? AppColorScheme.darkPrimary
                          : AppColorScheme.lightPrimary,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColorScheme.error,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColorScheme.error,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColorScheme.darkSurface
                      : AppColorScheme.lightSurface,
                ),
              ).animate().fadeIn().slideY(),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isVerifying
                        ? null
                        : () => Navigator.pop(context, false),
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
                    onPressed: _isVerifying ? null : _verifyAndEnableBiometrics,
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
                    child: _isVerifying
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isDark
                                    ? AppColorScheme.darkSurface
                                    : Colors.white,
                              ),
                            ),
                          )
                        : const Text('Enable'),
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
