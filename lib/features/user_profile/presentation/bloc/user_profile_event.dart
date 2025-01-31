import 'package:equatable/equatable.dart';

abstract class UserProfileEvent extends Equatable {
  const UserProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserProfile extends UserProfileEvent {}

class DeleteUserAccount extends UserProfileEvent {}

class LogoutUser extends UserProfileEvent {}
