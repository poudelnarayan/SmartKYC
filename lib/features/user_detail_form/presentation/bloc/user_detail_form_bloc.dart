import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartkyc/domain/usecases/update_user.dart';

import '../../../../core/services/storage_service.dart';
import 'user_detail_form_event.dart';
import 'user_detail_form_state.dart';

class UserBloc extends Bloc<UserEvent, UserAndFileState> {
  final updateUser = UpdateUser();

  UserBloc() : super(UserInitial()) {
    on<UpdateUserEvent>((event, emit) async {
      emit(UserUpdating());
      try {
        await updateUser.call(event.user);
        await Future.delayed(Duration(seconds: 3));
        emit(UserUpdated());
      } catch (e) {
        emit(UserUpdateError(e.toString()));
      }
    });

    on<UpploadFileEvent>((event, emit) async {
      emit(FileUploading());
      try {
        final storageService = StorageService();
        await storageService.uploadDocument(File(event.file.path));
        emit(FileUploaded());
      } catch (e) {
        emit(FileUploadError(e.toString()));
      }
    });
  }
}
