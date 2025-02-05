import 'package:equatable/equatable.dart';
import '../../../../domain/entities/user.dart';

abstract class UserProfileState extends Equatable {
  const UserProfileState();

  @override
  List<Object?> get props => [];
}

class UserProfileInitial extends UserProfileState {}

class UserProfileLoading extends UserProfileState {}

class UserProfileLoaded extends UserProfileState {
  final User user;

  const UserProfileLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class UserAccountDeleting extends UserProfileState {}

class UserAccountDeleted extends UserProfileState {}

class UserLoggingOut extends UserProfileState {}

class UserLoggedOut extends UserProfileState {}

class UserProfileError extends UserProfileState {
  final String message;

  const UserProfileError(this.message);

  @override
  List<Object?> get props => [message];
}


