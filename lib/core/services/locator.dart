import 'package:get_it/get_it.dart';
import 'package:smartkyc/core/services/preferences_service.dart';
import 'face_storage_service.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => OnboardingService());
  locator.registerLazySingleton(() => FaceStorageService());
}
