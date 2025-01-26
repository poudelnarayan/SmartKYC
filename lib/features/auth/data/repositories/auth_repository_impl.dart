import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/auth_user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepositoryImpl(this._firebaseAuth);

  @override
  Future<AuthUser> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user == null) {
        throw Exception('Failed to sign in');
      }

      return AuthUserModel.fromFirebaseUser(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  @override
  Future<AuthUser> signUpWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user == null) {
        throw Exception('Failed to sign up');
      }

      await userCredential.user!.sendEmailVerification();
      return AuthUserModel.fromFirebaseUser(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  @override
  Future<void> sendEmailVerificationCode(String email) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        await currentUser.sendEmailVerification();
      } else {
        throw Exception('No user signed in');
      }
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  // @override
  // Future<void> verifyEmailCode(String code) async {
  //   try {
  //     final currentUser = _firebaseAuth.currentUser;
  //     if (currentUser != null) {
  //       await currentUser.reload();
  //     } else {
  //       throw Exception('No user signed in');
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     throw _handleFirebaseAuthException(e);
  //   }
  // }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Exception _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return Exception('Invalid email address');
      case 'user-disabled':
        return Exception('This account has been disabled');
      case 'user-not-found':
        return Exception('No account found with this email');
      case 'wrong-password':
        return Exception('Invalid password');
      case 'email-already-in-use':
        return Exception('An account already exists with this email');
      case 'operation-not-allowed':
        return Exception('Operation not allowed');
      case 'weak-password':
        return Exception('Please enter a stronger password');
      default:
        return Exception(e.message ?? 'An error occurred');
    }
  }
}