import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required id,
    required email,
    required isEmailVerified,
  }) : super(email: email, id: id, isEmailVerified: isEmailVerified);

  factory AuthUserModel.fromFirebaseUser(firebase_auth.User user) {
    return AuthUserModel(
      id: user.uid,
      email: user.email ?? '',
      isEmailVerified: user.emailVerified,
    );
  }
}
