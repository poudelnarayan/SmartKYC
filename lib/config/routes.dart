import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartkyc/core/services/preferences_service.dart';
import 'package:smartkyc/features/auth/presentation/pages/singin_page.dart';
import 'package:smartkyc/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:smartkyc/features/liveliness_detection/presentation/pages/liveness_detection_start_page.dart';
import 'package:smartkyc/features/selfie_capture/presentation/pages/selfie_start_page.dart';
import 'package:smartkyc/features/user_detail_form/presentation/pages/user_detail_form_page.dart';
import 'package:smartkyc/features/user_profile/presentation/pages/user_profile_page.dart';
import '../features/auth/presentation/pages/sign_up_page.dart';
import '../features/auth/presentation/pages/sign_up_success.dart';
import '../features/auth/presentation/pages/verify_email_page.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import '../features/upload_document/presentation/pages/upload_document_page.dart';
import '../features/selfie_capture/presentation/pages/selfie_capture_page.dart';
import '../features/liveliness_detection/presentation/pages/liveness_detection_page.dart';
import '../features/success/presentation/pages/verification_success_page.dart';
import '../features/verification_steps/presentation/pages/verification_steps_page.dart';

final onboardingService = GetIt.instance<OnboardingService>();
bool isLoggedIn() => FirebaseAuth.instance.currentUser != null;

Future<String> handleKYCNavigation(BuildContext context,
    {String? skipStep}) async {
  final user = FirebaseAuth.instance.currentUser;
  

  final userDoc =
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();

  if (userDoc.data() == null && skipStep == null) {
    return UploadDocumentPage.pageName;
  }

  final bool isDocumentVerified = userDoc['isDocumentVerified'] ?? false;
  final bool isSelfieVerified = userDoc['isSelfieVerified'] ?? false;
  final bool isLivenessVerified = userDoc['isLivenessVerified'] ?? false;

  if (skipStep == 'document') {
    if (!isSelfieVerified) return SelfieStartPage.pageName;
    if (!isLivenessVerified) return LivenessDetectionStartPage.pageName;
    return UserProfilePage.pageName;
  }

  if (skipStep == 'selfie') {
    if (!isLivenessVerified) return LivenessDetectionStartPage.pageName;
    return UserProfilePage.pageName;
  }

  if (skipStep == 'liveness') {
    return UserProfilePage.pageName;
  }

  if (!isDocumentVerified) return UploadDocumentPage.pageName;
  if (!isSelfieVerified) return SelfieStartPage.pageName;
  if (!isLivenessVerified) return LivenessDetectionStartPage.pageName;

  return UserProfilePage.pageName;
}

final appRouter = GoRouter(
  initialLocation: onboardingService.hasSeenOnboarding
      ? SinginPage.pageName
      : OnboardingPage.pageName,
  routes: [
    GoRoute(
      path: SignUpSuccessPage.pageName,
      builder: (context, state) => SignUpSuccessPage(
        email: state.extra as String,
      ),
    ),
    GoRoute(
      name: OnboardingPage.pageName,
      path: OnboardingPage.pageName,
      builder: (context, state) => OnboardingPage(),
    ),
    GoRoute(
      name: SinginPage.pageName,
      path: SinginPage.pageName,
      builder: (context, state) => const SinginPage(),
    ),
    GoRoute(
      name: SignUpPage.pageName,
      path: SignUpPage.pageName,
      builder: (context, state) => const SignUpPage(),
    ),
    GoRoute(
      name: VerifyEmailPage.pageName,
      path: VerifyEmailPage.pageName,
      builder: (context, state) => const VerifyEmailPage(),
    ),
    GoRoute(
        name: UploadDocumentPage.pageName,
        path: UploadDocumentPage.pageName,
        builder: (context, state) => UploadDocumentPage(),
        routes: [
          GoRoute(
            name: UserDetailFormPage.pageName,
            path: UserDetailFormPage.pageName,
            builder: (context, state) => const UserDetailFormPage(),
          ),
        ]),
    GoRoute(
        name: SelfieStartPage.pageName,
        path: SelfieStartPage.pageName,
        builder: (context, state) => SelfieStartPage(),
        routes: [
          GoRoute(
            name: SelfieCapturePage.pageName,
            path: SelfieCapturePage.pageName,
            builder: (context, state) => SelfieCapturePage(),
          ),
        ]),
    GoRoute(
        name: LivenessDetectionStartPage.pageName,
        path: LivenessDetectionStartPage.pageName,
        builder: (context, state) => LivenessDetectionStartPage(),
        routes: [
          GoRoute(
            name: LivenessDetectoinPage.pageName,
            path: LivenessDetectoinPage.pageName,
            builder: (context, state) => LivenessDetectoinPage(),
          ),
        ]),
    GoRoute(
      name: VerificationSuccessPage.pageName,
      path: VerificationSuccessPage.pageName,
      builder: (context, state) => const VerificationSuccessPage(),
    ),
    GoRoute(
      name: UserProfilePage.pageName,
      path: UserProfilePage.pageName,
      builder: (context, state) => UserProfilePage(),
    ),
    GoRoute(
      name: VerificationStepsPage.pageName,
      path: VerificationStepsPage.pageName,
      builder: (context, state) => const VerificationStepsPage(),
    ),
    GoRoute(
      name: ForgotPasswordPage.pageName,
      path: ForgotPasswordPage.pageName,
      builder: (context, state) => ForgotPasswordPage(),
    )
  ],
  redirect: (context, state) {
    final isAuthenticated = isLoggedIn();

    final protectedRoutes = [
      SignUpSuccessPage.pageName,
      UploadDocumentPage.pageName,
      SelfieCapturePage.pageName,
      VerificationSuccessPage.pageName,
      LivenessDetectoinPage.pageName,
      VerificationStepsPage.pageName,
      LivenessDetectionStartPage.pageName,
      SelfieStartPage.pageName,
      UserProfilePage.pageName,
    ];

    final isTryingToAccessProtectedRoute =
        protectedRoutes.contains(state.matchedLocation);

    if (!isAuthenticated && isTryingToAccessProtectedRoute) {
      return SinginPage.pageName;
    }

    return null;
  },
);
