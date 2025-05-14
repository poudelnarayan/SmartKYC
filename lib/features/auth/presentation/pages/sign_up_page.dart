import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:smartkyc/core/theme/app_color_scheme.dart';
import 'package:smartkyc/l10n/app_localizations.dart';
import 'package:smartkyc/features/auth/presentation/pages/sign_up_success.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  static const pageName = "/signup";

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is SignUpSuccess) {
          context.go(SignUpSuccessPage.pageName, extra: state.email);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppDimensions.h48),
                    // Animated icon
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color:
                              (isDark ? AppColorScheme.darkText : Colors.white)
                                  .withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: (isDark
                                    ? AppColorScheme.darkText
                                    : Colors.white)
                                .withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.person_add_outlined,
                          size: AppDimensions.s48,
                          color:
                              (isDark ? AppColorScheme.darkText : Colors.white)
                                  .withOpacity(0.9),
                        ),
                      ),
                    ).animate().scale(),
                    const SizedBox(height: AppDimensions.h32),
                    // Title
                    Text(
                      l10n.createAccount,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: isDark ? AppColorScheme.darkText : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn().slideY(),
                    const SizedBox(height: 12),
                    // Subtitle
                    Text(
                      l10n.createAccountDesc,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: (isDark ? AppColorScheme.darkText : Colors.white)
                            .withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn().slideY(),
                    const SizedBox(height: 48),
                    // Email field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        color: isDark ? AppColorScheme.darkText : Colors.white,
                      ),
                      decoration: _getInputDecoration(
                        label: l10n.emailLabel,
                        icon: Icons.email_outlined,
                        isDark: isDark,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.emailRequired;
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return l10n.invalidEmail;
                        }
                        return null;
                      },
                    ).animate().fadeIn().slideX(),
                    const SizedBox(height: 16),
                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      style: TextStyle(
                        color: isDark ? AppColorScheme.darkText : Colors.white,
                      ),
                      decoration: _getInputDecoration(
                        label: l10n.passwordLabel,
                        icon: Icons.lock_outline_rounded,
                        isDark: isDark,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: (isDark
                                    ? AppColorScheme.darkText
                                    : Colors.white)
                                .withOpacity(0.7),
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.passwordRequired;
                        }
                        if (value.length < 8) {
                          return l10n.passwordTooShort;
                        }
                        return null;
                      },
                    ).animate().fadeIn().slideX(),
                    const SizedBox(height: 16),
                    // Confirm password field
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      style: TextStyle(
                        color: isDark ? AppColorScheme.darkText : Colors.white,
                      ),
                      decoration: _getInputDecoration(
                        label: l10n.confirmPassword,
                        icon: Icons.lock_outline_rounded,
                        isDark: isDark,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: (isDark
                                    ? AppColorScheme.darkText
                                    : Colors.white)
                                .withOpacity(0.7),
                          ),
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.confirmPasswordRequired;
                        }
                        if (value != _passwordController.text) {
                          return l10n.passwordsDoNotMatch;
                        }
                        return null;
                      },
                    ).animate().fadeIn().slideX(),
                    const SizedBox(height: 32),
                    // Sign up button
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return FilledButton.icon(
                          onPressed: state is AuthLoading
                              ? null
                              : () {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    context.read<AuthBloc>().add(
                                          SignUpWithEmailAndPassword(
                                            email: _emailController.text,
                                            password: _passwordController.text,
                                          ),
                                        );
                                  }
                                },
                          icon: state is AuthLoading
                              ? Container(
                                  width: 24,
                                  height: 24,
                                  padding: const EdgeInsets.all(2),
                                  child: CircularProgressIndicator(
                                    color: isDark
                                        ? AppColorScheme.darkSurface
                                        : Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Icon(Icons.person_add_outlined),
                          label: Text(
                            l10n.signUp,
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
                        ).animate().fadeIn().scale();
                      },
                    ),
                    const SizedBox(height: 24),
                    // Sign in link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.alreadyHaveAccount,
                          style: TextStyle(
                            color: (isDark
                                    ? AppColorScheme.darkText
                                    : Colors.white)
                                .withOpacity(0.9),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.pop(),
                          child: Text(
                            l10n.signIn,
                            style: TextStyle(
                              color: isDark
                                  ? AppColorScheme.darkText
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _getInputDecoration({
    required String label,
    required IconData icon,
    required bool isDark,
    Widget? suffixIcon,
  }) {
    final textColor = isDark ? AppColorScheme.darkText : Colors.white;

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: textColor.withOpacity(0.9)),
      prefixIcon: Icon(
        icon,
        color: textColor.withOpacity(0.7),
      ),
      errorStyle: const TextStyle(color: Colors.white),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: textColor.withOpacity(0.3),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: textColor.withOpacity(0.3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: textColor),
      ),
      filled: true,
      fillColor: textColor.withOpacity(0.1),
    );
  }
}
