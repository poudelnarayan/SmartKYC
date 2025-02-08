import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:smartkyc/core/services/locator.dart';
import 'package:smartkyc/core/services/preferences_service.dart';
import 'package:smartkyc/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:smartkyc/features/auth/domain/usecases/sign_in.dart';
import 'package:smartkyc/features/auth/domain/usecases/sign_up.dart';
import 'package:smartkyc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smartkyc/features/language/presentation/bloc/language_bloc.dart';
import 'package:smartkyc/features/liveliness_detection/presentation/bloc/liveliness_bloc.dart';
import 'package:smartkyc/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:smartkyc/features/theme/presentation/bloc/theme_bloc.dart';
import 'package:smartkyc/features/upload_document/presentation/bloc/upload_document_bloc.dart';
import 'package:smartkyc/features/user_detail_form/presentation/bloc/user_detail_form_bloc.dart';
import 'package:smartkyc/features/user_profile/presentation/bloc/user_profile_bloc.dart';
import 'package:smartkyc/l10n/app_localizations.dart';
import 'config/routes.dart';
import 'core/theme/app_theme.dart';
import 'domain/services/auth_service.dart';
import 'domain/usecases/delete_user.dart';
import 'domain/usecases/get_user.dart';
import 'domain/usecases/update_user.dart';
import 'features/theme/presentation/bloc/theme_state.dart';
import 'firebase_options.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();

  final onboardingService = GetIt.instance<OnboardingService>();
  await onboardingService.init();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Failed to initialize Firebase: $e');
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  final cameras = await availableCameras();
  getIt.registerSingleton<List<CameraDescription>>(cameras);

  // Initialize services and repositories
  final authRepository = AuthRepositoryImpl(FirebaseAuth.instance);
  final signInUseCase = SignInUseCase(authRepository);
  final signUpUseCase = SignUpUseCase(authRepository);
  final getUser = GetUser();
  final deleteUser = DeleteUser();
  final updateUser = UpdateUser();
  final authService = AuthService();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => OnboardingBloc()),
        BlocProvider(create: (context) => UploadDocumentBloc()),
        BlocProvider(create: (context) => LanguageBloc()),
        BlocProvider(create: (context) => LivenessBloc()),
        BlocProvider(create: (context) => UserBloc()),
        BlocProvider(create: (context) => ThemeBloc()),
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            signIn: signInUseCase,
            signUp: signUpUseCase,
            repository: authRepository,
          ),
        ),
        BlocProvider<UserProfileBloc>(
          create: (context) => UserProfileBloc(
            updateUser: updateUser,
            getUser: getUser,
            deleteUser: deleteUser,
          ),
        ),
      ],
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: SmartKycApp(authService: authService),
      ),
    ),
  );
}

class SmartKycApp extends StatelessWidget {
  final AuthService authService;

  const SmartKycApp({
    super.key,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, languageState) {
        return BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            return MaterialApp.router(
              title: 'SmartKYC',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeState.themeMode,
              locale: languageState.currentLocale,
              routerConfig: appRouter,
              builder: (context, child) {
                return Scaffold(
                  body: StreamBuilder<User?>(
                    stream: authService.authStateChanges,
                    builder: (context, snapshot) {
                      if (snapshot.data == null) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {});
                      }
                      return child ?? const SizedBox.shrink();
                    },
                  ),
                );
              },
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en'),
                Locale('ne'),
              ],
            );
          },
        );
      },
    );
  }
}
