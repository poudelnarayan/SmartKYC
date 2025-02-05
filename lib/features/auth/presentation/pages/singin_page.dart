import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:smartkyc/features/auth/presentation/pages/verify_email_page.dart';
import 'package:smartkyc/features/language/presentation/widgets/language_switcher.dart';
import '../../../../config/routes.dart';
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

  void _showErrorSnackBar(String error) {
    final errorDetails = _getErrorDetails(error, context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  errorDetails.icon,
                  color: Colors.white,
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (errorDetails.message.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        errorDetails.message,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
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
                    foregroundColor: Colors.white,
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
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthError) {
          _showErrorSnackBar(state.message);
        } else if (state is EmailVerificationRequired) {
          context.go(VerifyEmailPage.pageName);
        } else if (state is SigninSuccess) {
          await _checkNavigation();
          if (mounted) {
            Navigator.push(
              context,
              PageRouteBuilder(
                opaque: true,
                pageBuilder: (context, _, __) => VerificationProgressOverlay(
                  completedStep: 0,
                  nextRoute: nextRoute,
                ),
              ),
            );
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
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
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
                    const LoginForm(),
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
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Icon(
          Icons.lock_outline_rounded,
          size: 48,
          color: Colors.white.withOpacity(0.9),
        ),
      ),
    ).animate().scale();
  }

  Widget _buildWelcomeText(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Text(
          l10n.welcomeTitle,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ).animate().fadeIn().slideY(),
        const SizedBox(height: 8),
        Text(
          l10n.welcomeSubtitle,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
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

ErrorDetails _getErrorDetails(String error, context) {
  if (error.contains('user-not-found')) {
    return ErrorDetails(
      title: 'Account Not Found',
      message: 'Create a new account or try a different email',
      icon: Icons.person_off_outlined,
      color: const Color(0xFF323232),
      action: () => context.go('/signup'),
      actionLabel: 'Sign Up',
    );
  }

  if (error.contains('credential is incorrect')) {
    return ErrorDetails(
      title: 'Incorrect Email or Password',
      message: 'Please check your email or password and try again',
      icon: Icons.lock_outlined,
      color: const Color(0xFF323232),
    );
  }

  // Add other error cases...

  return ErrorDetails(
    title: 'Something Went Wrong',
    message: 'Please try again later',
    icon: Icons.error_outline,
    color: const Color(0xFF323232),
  );
}
