import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_color_scheme.dart';

class PasswordChangeModal extends StatefulWidget {
  const PasswordChangeModal({super.key});

  @override
  State<PasswordChangeModal> createState() => _PasswordChangeModalState();
}

class _PasswordChangeModalState extends State<PasswordChangeModal> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSuccessDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColorScheme.getCardBackground(isDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: AppColorScheme.getCardBorder(isDark),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColorScheme.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: AppColorScheme.success,
                size: 48,
              ),
            ).animate().scale(),
            const SizedBox(height: 24),
            Text(
              'Password Changed!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color:
                    isDark ? AppColorScheme.darkText : AppColorScheme.lightText,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn().slideY(),
            const SizedBox(height: 8),
            Text(
              'Your password has been updated successfully. Please use your new password the next time you sign in.',
              style: TextStyle(
                color: isDark
                    ? AppColorScheme.darkTextSecondary
                    : AppColorScheme.lightTextSecondary,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn().slideY(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close modal
                },
                style: FilledButton.styleFrom(
                  backgroundColor: isDark
                      ? AppColorScheme.darkPrimary
                      : AppColorScheme.lightPrimary,
                  foregroundColor:
                      isDark ? AppColorScheme.darkSurface : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ).animate().fadeIn().scale(),
          ],
        ),
      ),
    );
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user signed in');

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text,
      );
      await user.reauthenticateWithCredential(credential);

      // Change password
      await user.updatePassword(_newPasswordController.text);

      if (mounted) {
        context.pop();
        _showSuccessDialog();
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        print(e.code);
        if (e.code.contains('invalid-credential')) {
          _errorMessage = 'Current password is incorrect';
        } else if (e.code.contains('weak-password')) {
          _errorMessage = 'New password is too weak';
        } else if (e.code.contains('requires-recent-login')) {
          _errorMessage = 'Please sign in again to change password';
        } else {
          _errorMessage = e.message ?? 'Failed to change password';
        }
      });
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        bottom: 20,
      ),
      decoration: BoxDecoration(
        color: AppColorScheme.getCardBackground(isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColorScheme.darkCardBorder
                          : AppColorScheme.lightCardBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColorScheme.darkPrimary.withOpacity(0.1)
                            : AppColorScheme.lightPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.lock_outline,
                        color: isDark
                            ? AppColorScheme.darkPrimary
                            : AppColorScheme.lightPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Change Password',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColorScheme.darkText
                                  : AppColorScheme.lightText,
                            ),
                          ),
                          Text(
                            'Enter your current password to continue',
                            style: TextStyle(
                              color: isDark
                                  ? AppColorScheme.darkTextSecondary
                                  : AppColorScheme.lightTextSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ).animate().fadeIn().slideX(),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _currentPasswordController,
                  obscureText: !_showCurrentPassword,
                  style: TextStyle(
                    color: isDark
                        ? AppColorScheme.darkText
                        : AppColorScheme.lightText,
                  ),
                  decoration: _getInputDecoration(
                    isDark: isDark,
                    labelText: 'Current Password',
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showCurrentPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: isDark
                            ? AppColorScheme.darkTextSecondary
                            : AppColorScheme.lightTextSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _showCurrentPassword = !_showCurrentPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your current password';
                    }
                    return null;
                  },
                ).animate().fadeIn().slideX(),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: !_showNewPassword,
                  style: TextStyle(
                    color: isDark
                        ? AppColorScheme.darkText
                        : AppColorScheme.lightText,
                  ),
                  decoration: _getInputDecoration(
                    isDark: isDark,
                    labelText: 'New Password',
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showNewPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: isDark
                            ? AppColorScheme.darkTextSecondary
                            : AppColorScheme.lightTextSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _showNewPassword = !_showNewPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a new password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    if (!value.contains(RegExp(r'[A-Z]'))) {
                      return 'Password must contain at least one uppercase letter';
                    }
                    if (!value.contains(RegExp(r'[0-9]'))) {
                      return 'Password must contain at least one number';
                    }
                    return null;
                  },
                ).animate().fadeIn().slideX(),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_showConfirmPassword,
                  style: TextStyle(
                    color: isDark
                        ? AppColorScheme.darkText
                        : AppColorScheme.lightText,
                  ),
                  decoration: _getInputDecoration(
                    isDark: isDark,
                    labelText: 'Confirm New Password',
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: isDark
                            ? AppColorScheme.darkTextSecondary
                            : AppColorScheme.lightTextSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _showConfirmPassword = !_showConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your new password';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ).animate().fadeIn().slideX(),
                const SizedBox(height: 24),
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppColorScheme.error,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: AppColorScheme.error,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().shake(),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _changePassword,
                    style: FilledButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColorScheme.darkPrimary
                          : AppColorScheme.lightPrimary,
                      foregroundColor:
                          isDark ? AppColorScheme.darkSurface : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isDark
                                    ? AppColorScheme.darkSurface
                                    : Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Change Password',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
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

  InputDecoration _getInputDecoration({
    required bool isDark,
    required String labelText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(
        color: isDark
            ? AppColorScheme.darkTextSecondary
            : AppColorScheme.lightTextSecondary,
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: isDark
            ? AppColorScheme.darkTextSecondary
            : AppColorScheme.lightTextSecondary,
      ),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark
              ? AppColorScheme.darkCardBorder
              : AppColorScheme.lightCardBorder,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark
              ? AppColorScheme.darkCardBorder
              : AppColorScheme.lightCardBorder,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color:
              isDark ? AppColorScheme.darkPrimary : AppColorScheme.lightPrimary,
          width: 2,
        ),
      ),
      filled: true,
      fillColor:
          isDark ? AppColorScheme.darkSurface : AppColorScheme.lightSurface,
    );
  }
}
