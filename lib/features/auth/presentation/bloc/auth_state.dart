import 'package:equatable/equatable.dart';

import '../../domain/entities/auth_user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final AuthUser user;
  const AuthSuccess(this.user);

  @override
  List<Object?> get props => [user];
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

class SignedOut extends AuthState {}
