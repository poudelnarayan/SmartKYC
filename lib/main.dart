import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartkyc/config/routes.dart';
import 'package:camera/camera.dart';
import 'package:get_it/get_it.dart';
import 'package:smartkyc/features/language/presentation/bloc/language_bloc.dart';
import 'package:smartkyc/features/liveliness_detection/presentation/bloc/liveliness_bloc.dart';
import 'package:smartkyc/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:flutter/services.dart';
import 'package:smartkyc/features/upload_document/presentation/bloc/upload_document_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/sign_in.dart';
import 'features/auth/domain/usecases/sign_up.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'firebase_options.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final authRepository = AuthRepositoryImpl(FirebaseAuth.instance);
  final signInUseCase = SignInUseCase(authRepository);
  final signUpUseCase = SignUpUseCase(authRepository);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  final cameras = await availableCameras();
  getIt.registerSingleton<List<CameraDescription>>(cameras);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => OnboardingBloc()),
        BlocProvider(create: (context) => UploadDocumentBloc()),
        BlocProvider(create: (context) => LanguageBloc()),
        BlocProvider(create: (context) => LivenessBloc()),
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            signIn: signInUseCase,
            signUp: signUpUseCase,
            repository: authRepository,
          ),
        ),
      ],
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: SmartKycApp(),
      ),
    ),
  );
}

class SmartKycApp extends StatelessWidget {
  const SmartKycApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
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
          locale: state.currentLocale,
          routerConfig: appRouter,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ne'),
          ],
        );
      },
    );
  }
}
