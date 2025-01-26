import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_up.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

// Events


// States


// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signIn;
  final SignUpUseCase signUp;
  final AuthRepository repository;

  AuthBloc({
    required this.signIn,
    required this.signUp,
    required this.repository,
  }) : super(AuthInitial()) {
    on<SignInWithEmailAndPassword>(_onSignInWithEmailAndPassword);
    on<SignUpWithEmailAndPassword>(_onSignUpWithEmailAndPassword);
    on<SendEmailVerification>(_onSendEmailVerification);
    // on<VerifyEmailCode>(_onVerifyEmailCode);
    on<SendPasswordReset>(_onSendPasswordReset);
    on<SignOut>(_onSignOut);
  }

  Future<void> _onSignInWithEmailAndPassword(
    SignInWithEmailAndPassword event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      final user = await signIn(event.email, event.password);
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignUpWithEmailAndPassword(
    SignUpWithEmailAndPassword event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      final user = await signUp(event.email, event.password);
      emit(EmailVerificationSent(user.email));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSendEmailVerification(
    SendEmailVerification event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      await repository.sendEmailVerificationCode(event.email);
      emit(EmailVerificationSent(event.email));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Future<void> _onVerifyEmailCode(
  //   VerifyEmailCode event,
  //   Emitter<AuthState> emit,
  // ) async {
  //   try {
  //     emit(AuthLoading());
  //     await repository.verifyEmailCode(event.code);
  //     emit(EmailVerified());
  //   } catch (e) {
  //     emit(AuthError(e.toString()));
  //   }
  // }

  Future<void> _onSendPasswordReset(
    SendPasswordReset event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      await repository.sendPasswordResetEmail(event.email);
      emit(PasswordResetSent());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignOut(
    SignOut event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      await repository.signOut();
      emit(SignedOut());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}