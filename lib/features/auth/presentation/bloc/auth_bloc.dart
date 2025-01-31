import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartkyc/domain/entities/user.dart';
import 'package:smartkyc/domain/usecases/update_user.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_up.dart';
import '../../domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signIn;
  final SignUpUseCase signUp;
  final AuthRepository repository;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthBloc({
    required this.signIn,
    required this.signUp,
    required this.repository,
  }) : super(AuthInitial()) {
    on<SignInWithEmailAndPassword>(_onSignInWithEmailAndPassword);
    on<SignUpWithEmailAndPassword>(_onSignUpWithEmailAndPassword);
    on<SendEmailVerification>(_onSendEmailVerification);
    on<SendPasswordReset>(_onSendPasswordReset);
    on<SignOut>(_onSignOut);
  }

  Future<void> _onSignInWithEmailAndPassword(
    SignInWithEmailAndPassword event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());

      // Sign in with Firebase Auth
      final userCredential =
          await firebase_auth.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      if (userCredential.user == null) {
        emit(const AuthError('Failed to sign in'));
        return;
      }

      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        await UpdateUser().call(
          User(
            uid: userCredential.user!.uid,
            email: userCredential.user!.email!,
            licenseNumber: "N/A",
            firstName: "User",
            lastName: "Profile",
            dob: DateTime(0),
            fatherName: "N/A",
            citizenshipNumber: "N/A",
          ),
        );
      }

      if (!userCredential.user!.emailVerified) {
        emit(EmailVerificationRequired());
      } else {
        final user = await signIn(event.email, event.password);
        emit(SigninSuccess(user));
      }
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
      emit(SignUpSuccess(event.email));
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
      emit(SignOutSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
