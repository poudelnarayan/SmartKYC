import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class UploadDocumentEvent extends Equatable {
  const UploadDocumentEvent();

  @override
  List<Object?> get props => [];
}

class PickFromGallery extends UploadDocumentEvent {}

class CaptureFromCamera extends UploadDocumentEvent {}

class ResetUpload extends UploadDocumentEvent {}

class SetCapturedImage extends UploadDocumentEvent {
  final XFile image;

  const SetCapturedImage(this.image);

  @override
  List<Object?> get props => [image];
}
