import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class SignInWithEmailAndPassword extends AuthEvent {
  final String email;
  final String password;

  const SignInWithEmailAndPassword({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class SignUpWithEmailAndPassword extends AuthEvent {
  final String email;
  final String password;

  const SignUpWithEmailAndPassword({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class SendEmailVerification extends AuthEvent {
  final String email;

  const SendEmailVerification(this.email);

  @override
  List<Object?> get props => [email];
}

class VerifyEmailCode extends AuthEvent {
  final String code;

  const VerifyEmailCode(this.code);

  @override
  List<Object?> get props => [code];
}

class SendPasswordReset extends AuthEvent {
  final String email;

  const SendPasswordReset(this.email);

  @override
  List<Object?> get props => [email];
}

class SignOut extends AuthEvent {}
