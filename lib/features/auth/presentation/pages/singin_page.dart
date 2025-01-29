import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smartkyc/features/language/presentation/widgets/language_switcher.dart';
import 'package:smartkyc/features/upload_document/presentation/pages/upload_document_page.dart';
import '../../../verification_steps/presentation/widgets/verification_progress_overlay.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../widgets/email_input.dart';

class SinginPage extends StatelessWidget {
  const SinginPage({super.key});

  static const pageName = '/signin';

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is SigninSuccess) {
          // Navigate to home or next screen
          Navigator.push(
            context,
            PageRouteBuilder(
              opaque: true,
              pageBuilder: (context, _, __) => VerificationProgressOverlay(
                completedStep: 0,
                nextRoute: UploadDocumentPage.pageName,
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
