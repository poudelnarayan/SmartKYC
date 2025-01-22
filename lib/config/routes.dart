import 'package:go_router/go_router.dart';
import 'package:smartkyc/features/selfie_capture/presentation/pages/selfie_start_page.dart';
import 'package:smartkyc/features/user_profile/presentation/pages/user_profile_page.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import '../features/upload_document/presentation/pages/upload_document_page.dart';
import '../features/selfie_capture/presentation/pages/selfie_capture_page.dart';
import '../features/liveliness_detection/presentation/pages/liveliness_detection_page.dart';
import '../features/success/presentation/pages/success_page.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      name: "onboarding",
      path: '/',
      builder: (context, state) => OnboardingPage(),
    ),
    GoRoute(
      name: "upload-document",
      path: '/upload-document',
      builder: (context, state) => UploadDocumentPage(),
    ),
    GoRoute(
      name: "selfie-capture",
      path: '/selfie-capture',
      builder: (context, state) => SelfieCapturePage(),
    ),
    GoRoute(
      name: "liveliness-detection",
      path: '/liveliness-detection',
      builder: (context, state) => LivelinessDetectionPage(),
    ),
    GoRoute(
      name: "success",
      path: '/success',
      builder: (context, state) => SuccessPage(),
    ),
    GoRoute(
      name: "user-profile",
      path: '/user-profile',
      builder: (context, state) => UserProfilePage(),
    ),
    GoRoute(
      name: "selfie-start",
      path: '/selfie-start',
      builder: (context, state) => SelfieStartPage(),
    )
  ],
);
