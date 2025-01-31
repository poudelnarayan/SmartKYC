import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required String id,
    required String email,
    required bool isEmailVerified,
  }) : super(
          id: id,
          email: email,
          isEmailVerified: isEmailVerified,
        );

  factory AuthUserModel.fromFirebaseUser(firebase_auth.User user) {
    return AuthUserModel(
      id: user.uid,
      email: user.email ?? '',
      isEmailVerified: user.emailVerified,
    );
  }

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      isEmailVerified: json['isEmailVerified'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'isEmailVerified': isEmailVerified,
    };
  }

  AuthUserModel copyWith({
    String? id,
    String? email,
    bool? isEmailVerified,
  }) {
    return AuthUserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }
}
