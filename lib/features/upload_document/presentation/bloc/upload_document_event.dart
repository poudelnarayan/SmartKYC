import 'package:equatable/equatable.dart';

abstract class UploadDocumentEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class PickFromGallery extends UploadDocumentEvent {}

class CaptureFromCamera extends UploadDocumentEvent {}
