import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartkyc/config/routes.dart';
import 'package:camera/camera.dart';
import 'package:get_it/get_it.dart';
import 'package:smartkyc/features/liveliness_detection/presentation/bloc/liveliness_bloc.dart';
import 'package:smartkyc/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:flutter/services.dart';
import 'package:smartkyc/features/upload_document/presentation/bloc/upload_document_bloc.dart';

import 'features/selfie_capture/presentation/bloc/selfie_capture_bloc.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  final cameras = await availableCameras();
  getIt.registerSingleton<List<CameraDescription>>(cameras);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => OnboardingBloc()),
        BlocProvider(create: (context) => LivenessBloc()),
        BlocProvider(create: (context) => UploadDocumentBloc())
      ],
      child: const SmartKycApp(),
    ),
  );
}

class SmartKycApp extends StatelessWidget {
  const SmartKycApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'KYC verification',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          secondary: const Color(0xFF3B82F6),
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
      routerConfig: appRouter,
    );
  }
}
