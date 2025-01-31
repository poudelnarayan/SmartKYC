import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/user.dart';
import '../../../../domain/usecases/get_user.dart';
import '../../../../domain/usecases/delete_user.dart';
import 'user_profile_event.dart';
import 'user_profile_state.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final GetUser _getUser;
  final DeleteUser _deleteUser;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  UserProfileBloc({
    required GetUser getUser,
    required DeleteUser deleteUser,
  })  : _getUser = getUser,
        _deleteUser = deleteUser,
        super(UserProfileInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<DeleteUserAccount>(_onDeleteUserAccount);
    on<LogoutUser>(_onLogoutUser);
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    try {
      emit(UserProfileLoading());

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        emit(const UserProfileError('No authenticated user found'));
        return;
      }

      final user = await _getUser(currentUser.uid);
      emit(UserProfileLoaded(user));
    } catch (e) {
      print('Error loading user profile: $e');
      emit(UserProfileError(e.toString()));
    }
  }

  Future<void> _onDeleteUserAccount(
    DeleteUserAccount event,
    Emitter<UserProfileState> emit,
  ) async {
    try {
      emit(UserAccountDeleting());

      await _deleteUser();

      // Important: Emit UserAccountDeleted state after successful deletion
      emit(UserAccountDeleted());
    } catch (e) {
      print('Error deleting user account: $e');
      emit(UserProfileError(e.toString()));
    }
  }

  Future<void> _onLogoutUser(
    LogoutUser event,
    Emitter<UserProfileState> emit,
  ) async {
    try {
      emit(UserLoggingOut());
      await _auth.signOut();
      emit(UserLoggedOut());
    } catch (e) {
      print('Error logging out: $e');
      emit(UserProfileError(e.toString()));
    }
  }
}
