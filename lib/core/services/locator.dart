import 'package:get_it/get_it.dart';
import 'package:smartkyc/core/services/preferences_service.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => OnboardingService());
}
