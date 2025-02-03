import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smartkyc/config/routes.dart';
import 'package:smartkyc/features/auth/presentation/pages/verify_email_page.dart';
import 'package:smartkyc/features/upload_document/presentation/pages/upload_document_page.dart';
import '../../../verification_steps/presentation/widgets/verification_progress_overlay.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../widgets/email_input.dart';

class SinginPage extends StatefulWidget {
  const SinginPage({super.key});

  static const pageName = '/signin';

  @override
  State<SinginPage> createState() => _SinginPageState();
}

class _SinginPageState extends State<SinginPage> {
  String nextRoute = UploadDocumentPage.pageName;

  Future<void> _checkNavigation() async {
    final route = await handleKYCNavigation(context);
    if (mounted) {
      setState(() {
        nextRoute = route;
      });
    }
  }

  void _showErrorSnackBar(String error) {
    final errorDetails = _getErrorDetails(error);

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

  ErrorDetails _getErrorDetails(String error) {
    // Authentication Errors
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
        title: 'Incorrect Email or  Password',
        message: 'Please check your email or password and try again',
        icon: Icons.lock_outlined,
        color: const Color(0xFF323232),
      );
    }

    if (error.contains('invalid-email')) {
      return ErrorDetails(
        title: 'Invalid Email',
        message: 'Please enter a valid email address',
        icon: Icons.alternate_email,
        color: const Color(0xFF323232),
      );
    }

    if (error.contains('user-disabled')) {
      return ErrorDetails(
        title: 'Account Disabled',
        message: 'Contact support for assistance',
        icon: Icons.block_outlined,
        color: const Color(0xFF323232),
      );
    }

    if (error.contains('too-many-requests')) {
      return ErrorDetails(
        title: 'Too Many Attempts',
        message: 'Please try again after some time',
        icon: Icons.timer_outlined,
        color: const Color(0xFF323232),
      );
    }

    if (error.contains('network-request-failed')) {
      return ErrorDetails(
        title: 'Connection Error',
        message: 'Check your internet connection',
        icon: Icons.wifi_off_outlined,
        color: const Color(0xFF323232),
        action: () => _retryConnection(),
        actionLabel: 'Retry',
      );
    }

    return ErrorDetails(
      title: 'Something Went Wrong',
      message: 'Please try again later',
      icon: Icons.error_outline,
      color: const Color(0xFF323232),
    );
  }

  void _retryConnection() {
    // Add retry logic here
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
            child: const SafeArea(
              child: EmailInput(),
            ),
          ),
        );
      },
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
