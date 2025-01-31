import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smartkyc/config/routes.dart';
import 'package:smartkyc/features/language/presentation/widgets/language_switcher.dart';
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
  String nextRoute = '';

  @override
  void initState() {
    super.initState();
    _checkNavigation(); // Call the async function separately
  }

  Future<void> _checkNavigation() async {
    final route = await handleKYCNavigation(context);
    if (mounted) {
      setState(() {
        nextRoute = route;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is SigninSuccess) {
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
