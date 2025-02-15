import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:smartkyc/core/theme/app_color_scheme.dart';
import 'package:smartkyc/domain/entities/user.dart';
import 'package:smartkyc/domain/usecases/get_user.dart';
import 'package:smartkyc/features/auth/presentation/pages/sign_up_page.dart';
import 'package:smartkyc/features/auth/presentation/pages/verify_email_page.dart';
import 'package:smartkyc/features/auth/presentation/widgets/biometric_prompt_dialog.dart';
import 'package:smartkyc/features/user_profile/presentation/pages/user_profile_page.dart';
import '../../../../config/routes.dart';
import '../../../../core/services/biometric_services.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../verification_steps/presentation/widgets/verification_progress_overlay.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../widgets/login_form.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  static const pageName = '/signin';

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  String nextRoute = '/upload-document';

  Future<void> _checkNavigation() async {
    final route = await handleKYCNavigation(context);
    if (mounted) {
      setState(() {
        nextRoute = route;
      });
    }
  }

  String _email = '';
  String _password = '';

  void updateValues(String email, String password) {
    setState(() {
      _email = email;
      _password = password;
    });
  }

  void _showErrorSnackBar(String error) {
    final errorDetails = _getErrorDetails(error, context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColorScheme.getCardBackground(isDark)
                      .withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  errorDetails.icon,
                  color: isDark ? AppColorScheme.darkText : Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      errorDetails.title,
                      style: TextStyle(
                        color: isDark ? AppColorScheme.darkText : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (errorDetails.message.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        errorDetails.message,
                        style: TextStyle(
                          color:
                              (isDark ? AppColorScheme.darkText : Colors.white)
                                  .withOpacity(0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (errorDetails.action != null)
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    errorDetails.action!();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor:
                        isDark ? AppColorScheme.darkText : Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Text(
                    errorDetails.actionLabel ?? 'Action',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: errorDetails.color,
        duration: const Duration(seconds: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthError) {
          _showErrorSnackBar(state.message);
        } else if (state is EmailVerificationRequired) {
          context.go(VerifyEmailPage.pageName);
        } else if (state is SigninSuccess) {
          FocusScope.of(context).unfocus();
          SystemChannels.textInput.invokeMethod('TextInput.hide');

          final isBiometricEnabled =
              await BiometricService.isBiometricEnabled();

          if (!isBiometricEnabled) {
            // Check if biometrics are available on the device
            final isAvailable = await BiometricService.isBiometricsAvailable();
            if (isAvailable && mounted) {
              // Show biometric prompt
              await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (context) => BiometricPromptDialog(
                  email: _email,
                  password: _password,
                  isfirstTimeSignin: true,
                ),
              );
            }
          }

          final User user = await GetUser().call();

          // After biometric setup (or if skipped/not available), proceed with navigation
          if (mounted) {
            if (!user.isEmailVerified ||
                !user.isDocumentVerified ||
                !user.isSelfieVerified ||
                !user.isLivenessVerified) {
              await _checkNavigation();
              if (mounted) {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    opaque: true,
                    pageBuilder: (context, _, __) =>
                        VerificationProgressOverlay(
                      completedStep: 0,
                      nextRoute: nextRoute,
                    ),
                  ),
                );
              }
            } else {
              context.go(UserProfilePage.pageName);
            }
          }
        }
      },
      builder: (context, state) {
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // const LanguageSwitcher(),
                    const SizedBox(height: 48),
                    _buildLogo(context),
                    const SizedBox(height: 32),
                    _buildWelcomeText(context),
                    const SizedBox(height: 48),
                    LoginForm(
                      onValuesChanged: updateValues,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogo(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: (isDark ? AppColorScheme.darkText : Colors.white)
              .withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(
            color: (isDark ? AppColorScheme.darkText : Colors.white)
                .withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Icon(
          Icons.lock_outline_rounded,
          size: 48,
          color: (isDark ? AppColorScheme.darkText : Colors.white)
              .withOpacity(0.9),
        ),
      ),
    ).animate().scale();
  }

  Widget _buildWelcomeText(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Text(
          l10n.welcomeTitle,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: isDark ? AppColorScheme.darkText : Colors.white,
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ).animate().fadeIn().slideY(),
        const SizedBox(height: 8),
        Text(
          l10n.welcomeSubtitle,
          style: TextStyle(
            color: (isDark ? AppColorScheme.darkText : Colors.white)
                .withOpacity(0.9),
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn().slideY(),
      ],
    );
  }
}

class ErrorDetails {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final VoidCallback? action;
  final String? actionLabel;

  ErrorDetails({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    this.action,
    this.actionLabel,
  });
}

ErrorDetails _getErrorDetails(String error, BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final backgroundColor =
      isDark ? AppColorScheme.darkSurface : const Color(0xFF323232);

  if (error.contains('user-not-found')) {
    return ErrorDetails(
      title: 'Account Not Found',
      message: 'Create a new account or try a different email',
      icon: Icons.person_off_outlined,
      color: backgroundColor,
      action: () => context.go(SignUpPage.pageName),
      actionLabel: 'Sign Up',
    );
  }

  if (error.contains('credential is incorrect')) {
    return ErrorDetails(
      title: 'Incorrect Email or Password',
      message: 'Please check your email or password and try again',
      icon: Icons.lock_outlined,
      color: backgroundColor,
    );
  }

  return ErrorDetails(
    title: 'Something Went Wrong',
    message: 'Please try again later',
    icon: Icons.error_outline,
    color: backgroundColor,
  );
}
