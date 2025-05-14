import 'package:equatable/equatable.dart';

import '../../domain/entities/auth_user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class SigninSuccess extends AuthState {
  final AuthUser user;
  const SigninSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class EmailVerificationRequired extends AuthState {}

class SignUpSuccess extends AuthState {
  final String email;
  const SignUpSuccess(this.email);

  @override
  List<Object?> get props => [email];
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class EmailVerificationSent extends AuthState {
  final String email;
  const EmailVerificationSent(this.email);

  @override
  List<Object?> get props => [email];
}

class EmailVerified extends AuthState {}

class PasswordResetSent extends AuthState {}

class SignOutSuccess extends AuthState {}
