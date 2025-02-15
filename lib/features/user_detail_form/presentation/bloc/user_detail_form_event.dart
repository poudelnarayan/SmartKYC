import 'dart:io';

import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:smartkyc/domain/entities/user.dart';

abstract class UserEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class UpdateUserEvent extends UserEvent {
  final User user;

  UpdateUserEvent(this.user);

  @override
  List<Object> get props => [user];
}

class UpploadFileEvent extends UserEvent {
  final XFile file;

  UpploadFileEvent(this.file);

  @override
  List<Object> get props => [file];
}
