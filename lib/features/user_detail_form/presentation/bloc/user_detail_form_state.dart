import 'package:equatable/equatable.dart';

abstract class UserAndFileState extends Equatable {
  @override
  List<Object> get props => [];
}

class UserState extends UserAndFileState {}

class FileState extends UserAndFileState {}

class UserInitial extends UserState {}

class UserUpdating extends UserState {}

class UserUpdated extends UserState {}

class FileUploading extends FileState {}

class FileUploaded extends FileState {}

class UserUpdateError extends UserState {
  final String message;
  UserUpdateError(this.message);

  @override
  List<Object> get props => [message];
}

class FileUploadError extends UserState {
  final String message;
  FileUploadError(this.message);

  @override
  List<Object> get props => [message];
}
