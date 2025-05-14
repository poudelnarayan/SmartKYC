import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  bool _hasSeenOnboarding = false;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
  }

  bool get hasSeenOnboarding => _hasSeenOnboarding;

  Future<void> setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    _hasSeenOnboarding = true;
  }
}
