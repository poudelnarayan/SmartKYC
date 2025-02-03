import '../entities/auth_user.dart';

abstract class AuthRepository {
  Future<AuthUser> signInWithEmailAndPassword(String email, String password);
  Future<AuthUser> signUpWithEmailAndPassword(String email, String password);
  Future<void> sendPasswordResetEmail(String email);
  Future<void> sendEmailVerificationLink(String email);
  Future<void> sendPhoneNumberVerificationCode(String email);
  Future<void> signOut();
}
