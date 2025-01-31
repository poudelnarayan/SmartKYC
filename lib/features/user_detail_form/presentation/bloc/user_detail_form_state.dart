import 'package:equatable/equatable.dart';

abstract class UserState extends Equatable {
  @override
  List<Object> get props => [];
}

class UserInitial extends UserState {}

class UserUpdating extends UserState {}

class UserUpdated extends UserState {}

class UserUpdateError extends UserState {
  final String message;
  UserUpdateError(this.message);

  @override
  List<Object> get props => [message];
}
