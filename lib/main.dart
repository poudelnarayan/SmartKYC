import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartkyc/config/routes.dart';
import 'package:camera/camera.dart';
import 'package:get_it/get_it.dart';
import 'package:smartkyc/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:flutter/services.dart';

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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerConfig: appRouter,
    );
  }
}
