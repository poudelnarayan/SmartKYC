import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartkyc/core/theme/app_color_scheme.dart';
import 'package:smartkyc/features/auth/presentation/bloc/auth_bloc.dart';

import '../../../../core/services/biometric_services.dart';
import '../bloc/auth_event.dart';

class BiometricLoginText extends StatelessWidget {
  const BiometricLoginText({super.key});

  Future<void> _handleBiometricLogin(BuildContext context) async {
    try {
      final isAuthenticated = await BiometricService.authenticate();
      if (!isAuthenticated) return;

      final credentials = await BiometricService.getSavedCredentials();
      final email = credentials['email'];
      final password = credentials['password'];

      if (email == null || password == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Biometric login not set up')),
          );
        }
        return;
      }

      if (context.mounted) {
        context.read<AuthBloc>().add(
              SignInWithEmailAndPassword(
                email: email,
                password: password,
              ),
            );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Biometric login failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<bool>(
      future: BiometricService.isBiometricEnabled(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () => _handleBiometricLogin(context),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fingerprint,
                color: Colors.white,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                "Sign in with biometrics",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
