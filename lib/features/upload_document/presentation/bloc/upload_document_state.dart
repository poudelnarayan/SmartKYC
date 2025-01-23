import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class UploadDocumentState extends Equatable {
  const UploadDocumentState();

  @override
  List<Object?> get props => [];
}

class UploadInitial extends UploadDocumentState {}

class UploadInProgress extends UploadDocumentState {}

class UploadSuccess extends UploadDocumentState {
  final XFile file;

  const UploadSuccess(this.file);

  @override
  List<Object?> get props => [file.path];
}

class UploadFailure extends UploadDocumentState {
  final String error;

  const UploadFailure(this.error);

  @override
  List<Object?> get props => [error];
}
