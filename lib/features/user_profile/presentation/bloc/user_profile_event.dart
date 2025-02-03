import 'package:equatable/equatable.dart';

import '../../../../domain/entities/user.dart';

abstract class UserProfileEvent extends Equatable {
  const UserProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserProfile extends UserProfileEvent {}

class UpdateUserProfile extends UserProfileEvent {
  final User user;

  const UpdateUserProfile(this.user);

  @override
  List<Object?> get props => [user];
}

class DeleteUserAccount extends UserProfileEvent {}

class LogoutUser extends UserProfileEvent {}
