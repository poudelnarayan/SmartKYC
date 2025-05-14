import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class UploadDocumentState extends Equatable {
  const UploadDocumentState();

  @override
  List<Object?> get props => [];
}

abstract class PreviewDocumentState extends UploadDocumentState {}

class DocumentPreviewInitial extends PreviewDocumentState {}

class DocumentPreviewInProgress extends PreviewDocumentState {}

class DocumentPreviewSuccess extends PreviewDocumentState {
  final XFile file;

  DocumentPreviewSuccess(this.file);

  @override
  List<Object?> get props => [file.path];
}

class DocumentPreviewFailure extends PreviewDocumentState {
  final String error;

  DocumentPreviewFailure(this.error);

  @override
  List<Object?> get props => [error];
}
