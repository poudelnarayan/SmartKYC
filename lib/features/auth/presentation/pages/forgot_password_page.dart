import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smartkyc/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:smartkyc/core/constants/app_dimensions.dart';
import 'package:smartkyc/core/theme/app_color_scheme.dart';
import 'package:smartkyc/features/auth/presentation/pages/singin_page.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  static const pageName = "/forgotPassword";

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _showResetSuccessDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColorScheme.getCardBackground(isDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppColorScheme.getCardBorder(isDark),
          ),
        ),
        icon: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            color: Colors.green,
            size: AppDimensions.s32,
          ),
        ),
        title: Text(
          l10n.resetLinkSent,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? AppColorScheme.darkText : AppColorScheme.lightText,
          ),
        ),
        content: Text(
          l10n.resetLinkSentDesc,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark
                ? AppColorScheme.darkTextSecondary
                : AppColorScheme.lightTextSecondary,
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              context.go(SigninPage.pageName);
            },
            style: FilledButton.styleFrom(
              backgroundColor: isDark
                  ? AppColorScheme.darkPrimary
                  : AppColorScheme.lightPrimary,
              foregroundColor:
                  isDark ? AppColorScheme.darkSurface : Colors.white,
              minimumSize: const Size(double.infinity, AppDimensions.s48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n.backToSignIn),
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                      onPressed: () {
                        context.pop();
                      },
                      icon: Icon(Icons.arrow_back)),
                  const SizedBox(height: AppDimensions.s48),
                  // Icon
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColorScheme.darkText : Colors.white)
                            .withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_reset_outlined,
                        size: AppDimensions.s48,
                        color: (isDark ? AppColorScheme.darkText : Colors.white)
                            .withOpacity(0.9),
                      ),
                    ),
                  ).animate().scale(),
                  const SizedBox(height: AppDimensions.h32),
                  // Title
                  Center(
                    child: Text(
                      l10n.forgotPassword,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: isDark ? AppColorScheme.darkText : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn().slideY(),
                  ),
                  const SizedBox(height: AppDimensions.h12),
                  // Description
                  Text(
                    l10n.forgotPasswordDesc,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: (isDark ? AppColorScheme.darkText : Colors.white)
                          .withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn().slideY(),
                  const SizedBox(height: AppDimensions.h48),
                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                      color: isDark ? AppColorScheme.darkText : Colors.white,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.emailLabel,
                      labelStyle: TextStyle(
                        color: (isDark ? AppColorScheme.darkText : Colors.white)
                            .withOpacity(0.9),
                      ),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: (isDark ? AppColorScheme.darkText : Colors.white)
                            .withOpacity(0.7),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color:
                              (isDark ? AppColorScheme.darkText : Colors.white)
                                  .withOpacity(0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color:
                              (isDark ? AppColorScheme.darkText : Colors.white)
                                  .withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color:
                              isDark ? AppColorScheme.darkText : Colors.white,
                        ),
                      ),
                      filled: true,
                      fillColor:
                          (isDark ? AppColorScheme.darkText : Colors.white)
                              .withOpacity(0.1),
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
                  const SizedBox(height: AppDimensions.h32),
                  // Reset button
                  BlocConsumer<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state is PasswordResetSent) {
                        _showResetSuccessDialog(context);
                      } else if (state is AuthError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      return FilledButton.icon(
                        onPressed: state is AuthLoading
                            ? null
                            : () {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  context.read<AuthBloc>().add(
                                        SendPasswordReset(
                                          _emailController.text,
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
                            : const Icon(Icons.send_outlined),
                        label: Text(
                          l10n.resetPassword,
                          style: const TextStyle(
                            fontSize: AppDimensions.s16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              isDark ? AppColorScheme.darkText : Colors.white,
                          foregroundColor: theme.colorScheme.primary,
                          minimumSize:
                              const Size(double.infinity, AppDimensions.s56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ).animate().fadeIn().scale();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
