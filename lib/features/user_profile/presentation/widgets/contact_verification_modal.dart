import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartkyc/core/theme/app_color_scheme.dart';
import 'package:smartkyc/features/user_profile/presentation/bloc/user_profile_bloc.dart';
import 'package:smartkyc/features/user_profile/presentation/bloc/user_profile_event.dart';
import '../../../../l10n/app_localizations.dart';

class ContactVerificationModal extends StatefulWidget {
  final String currentValue;
  final Function(String) onVerified;

  const ContactVerificationModal({
    super.key,
    required this.currentValue,
    required this.onVerified,
  });

  @override
  State<ContactVerificationModal> createState() =>
      _ContactVerificationModalState();
}

class _ContactVerificationModalState extends State<ContactVerificationModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _controller;
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _verifyEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user signed in');

      String? password = await _showPasswordVerification();
      if (password == null || password.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      await user.verifyBeforeUpdateEmail(_controller.text);

      Navigator.pop(context);
      context.read<UserProfileBloc>().add(LoadUserProfile());

      if (mounted) {
        _showSuccessAnimation();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<String?> _showPasswordVerification() async {
    final passwordController = TextEditingController();
    bool isPasswordVisible = false;
    String? errorText;
    bool isLoading = false;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: AppColorScheme.getCardBackground(isDark),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColorScheme.darkCardBorder
                            : AppColorScheme.lightCardBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            (isDark
                                    ? AppColorScheme.darkPrimary
                                    : AppColorScheme.lightPrimary)
                                .withOpacity(0.1),
                            (isDark
                                    ? AppColorScheme.darkSecondary
                                    : AppColorScheme.lightSecondary)
                                .withOpacity(0.1),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_outline_rounded,
                        size: 40,
                        color: isDark
                            ? AppColorScheme.darkPrimary
                            : AppColorScheme.lightPrimary,
                      ),
                    )
                        .animate()
                        .scale(duration: const Duration(milliseconds: 300))
                        .then()
                        .shimmer(duration: const Duration(milliseconds: 1200)),
                    const SizedBox(height: 24),
                    Text(
                      'Verify It\'s You',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColorScheme.darkText
                                : AppColorScheme.lightText,
                          ),
                    ).animate().fadeIn().slideY(),
                    const SizedBox(height: 8),
                    Text(
                      'Please enter your current password to continue',
                      style: TextStyle(
                        color: isDark
                            ? AppColorScheme.darkTextSecondary
                            : AppColorScheme.lightTextSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn().slideY(),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: passwordController,
                      obscureText: !isPasswordVisible,
                      enabled: !isLoading,
                      autofocus: true,
                      onChanged: (_) => setState(() => errorText = null),
                      style: TextStyle(
                        color: isDark
                            ? AppColorScheme.darkText
                            : AppColorScheme.lightText,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          color: isDark
                              ? AppColorScheme.darkTextSecondary
                              : AppColorScheme.lightTextSecondary,
                        ),
                        errorText: errorText,
                        prefixIcon: Icon(
                          Icons.password_rounded,
                          color: errorText != null
                              ? AppColorScheme.error
                              : isDark
                                  ? AppColorScheme.darkTextSecondary
                                  : AppColorScheme.lightTextSecondary,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: errorText != null
                                ? AppColorScheme.error
                                : isDark
                                    ? AppColorScheme.darkTextSecondary
                                    : AppColorScheme.lightTextSecondary,
                          ),
                          onPressed: () => setState(
                              () => isPasswordVisible = !isPasswordVisible),
                        ),
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
                            color: isDark
                                ? AppColorScheme.darkPrimary
                                : AppColorScheme.lightPrimary,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppColorScheme.error,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppColorScheme.error,
                            width: 2,
                          ),
                        ),
                        errorStyle: TextStyle(
                          color: AppColorScheme.error,
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
                            onPressed:
                                isLoading ? null : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 24,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              side: BorderSide(
                                color: isDark
                                    ? AppColorScheme.darkCardBorder
                                    : AppColorScheme.lightCardBorder,
                              ),
                              foregroundColor: isDark
                                  ? AppColorScheme.darkText
                                  : AppColorScheme.lightText,
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FilledButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    setState(() {
                                      isLoading = true;
                                      errorText = null;
                                    });

                                    try {
                                      final credential =
                                          EmailAuthProvider.credential(
                                        email: _auth.currentUser!.email!,
                                        password: passwordController.text,
                                      );
                                      await _auth.currentUser!
                                          .reauthenticateWithCredential(
                                              credential);
                                      Navigator.pop(
                                          context, passwordController.text);
                                    } on FirebaseAuthException catch (e) {
                                      setState(() {
                                        errorText = switch (e.code) {
                                          'invalid-credential' =>
                                            'Incorrect password',
                                          'too-many-requests' =>
                                            'Too many attempts. Try again later',
                                          _ => 'Authentication failed',
                                        };
                                        isLoading = false;
                                      });
                                    } catch (e) {
                                      setState(() {
                                        errorText = 'An error occurred';
                                        isLoading = false;
                                      });
                                    }
                                  },
                            style: FilledButton.styleFrom(
                              backgroundColor: isDark
                                  ? AppColorScheme.darkPrimary
                                  : AppColorScheme.lightPrimary,
                              foregroundColor: isDark
                                  ? AppColorScheme.darkSurface
                                  : Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 24,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: isLoading
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
                                : const Text('Verify'),
                          ),
                        ),
                      ],
                    ).animate().fadeIn().slideY(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSuccessAnimation() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
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
                'Verification Email Sent',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColorScheme.darkText
                      : AppColorScheme.lightText,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn().slideY(),
              const SizedBox(height: 8),
              Text(
                'Please check your email at\n${_controller.text}',
                style: TextStyle(
                  color: isDark
                      ? AppColorScheme.darkTextSecondary
                      : AppColorScheme.lightTextSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn().slideY(),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: isDark
                      ? AppColorScheme.darkPrimary
                      : AppColorScheme.lightPrimary,
                  foregroundColor:
                      isDark ? AppColorScheme.darkSurface : Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Got it'),
              ).animate().fadeIn().scale(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.only(bottom: 30),
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
                Text(
                  l10n.updateEmail,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColorScheme.darkText
                        : AppColorScheme.lightText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.updateEmailDesc,
                  style: TextStyle(
                    color: isDark
                        ? AppColorScheme.darkTextSecondary
                        : AppColorScheme.lightTextSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _controller,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(
                    color: isDark
                        ? AppColorScheme.darkText
                        : AppColorScheme.lightText,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.emailLabel,
                    labelStyle: TextStyle(
                      color: isDark
                          ? AppColorScheme.darkTextSecondary
                          : AppColorScheme.lightTextSecondary,
                    ),
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: isDark
                          ? AppColorScheme.darkTextSecondary
                          : AppColorScheme.lightTextSecondary,
                    ),
                    errorText: _errorMessage,
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
                        color: isDark
                            ? AppColorScheme.darkPrimary
                            : AppColorScheme.lightPrimary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: isDark
                        ? AppColorScheme.darkSurface
                        : AppColorScheme.lightSurface,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.fieldRequired;
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return l10n.invalidEmail;
                    }
                    if (_controller.text == widget.currentValue) {
                      return "Please enter new email to change. ";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _verifyEmail,
                    style: FilledButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColorScheme.darkPrimary
                          : AppColorScheme.lightPrimary,
                      foregroundColor:
                          isDark ? AppColorScheme.darkSurface : Colors.white,
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
                        : Text(l10n.update),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
