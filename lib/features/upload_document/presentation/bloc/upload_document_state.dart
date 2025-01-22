import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class UploadDocumentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UploadInitial extends UploadDocumentState {}

class UploadInProgress extends UploadDocumentState {}

class UploadSuccess extends UploadDocumentState {
  final XFile file;
  UploadSuccess(this.file);

  @override
  List<Object?> get props => [file];
}

class UploadFailure extends UploadDocumentState {
  final String error;
  UploadFailure(this.error);

  @override
  List<Object?> get props => [error];
}
