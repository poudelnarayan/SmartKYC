import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricEmailKey = 'biometric_email';
  static const String _biometricPasswordKey = 'biometric_password';

  // Check if biometrics are available
  static Future<bool> isBiometricsAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } catch (e) {
      print('Error checking biometrics: $e');
      return false;
    }
  }

  // Get available biometric types
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      print('Error getting available biometrics: $e');
      return [];
    }
  }

  // Authenticate with biometrics
  static Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Please authenticate to sign in',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      print('Error authenticating: $e');
      return false;
    }
  }

  // Save biometric preferences

  static Future<void> saveBiometricCredentials({
    required String email,
    required String password,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_biometricEnabledKey, true);
      await prefs.setString(_biometricEmailKey, email);
      await prefs.setString(_biometricPasswordKey, password);
    } catch (e) {
      print('Error saving biometric credentials: $e');
    }
  }

  static Future<String?> get email async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_biometricEmailKey);
    } catch (e) {
      print('Error getting email from preferences: $e');
      return null;
    }
  }

  // Get saved credentials
  static Future<Map<String, String?>> getSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'email': prefs.getString(_biometricEmailKey),
        'password': prefs.getString(_biometricPasswordKey),
      };
    } catch (e) {
      print('Error getting saved credentials: $e');
      return {'email': null, 'password': null};
    }
  }

  // Check if biometric login is enabled
  static Future<bool> isBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_biometricEnabledKey) ?? false;
    } catch (e) {
      print('Error checking biometric enabled: $e');
      return false;
    }
  }

  // Disable biometric login
  static Future<void> disableBiometric() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_biometricEnabledKey, false);
      await prefs.remove(_biometricEmailKey);
      await prefs.remove(_biometricPasswordKey);
    } catch (e) {
      print('Error disabling biometric: $e');
    }
  }
}
