import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'upload_document_event.dart';
import 'upload_document_state.dart';

class UploadDocumentBloc extends Bloc<UploadDocumentEvent, UploadDocumentState> {
  final ImagePicker _picker = ImagePicker();

  UploadDocumentBloc() : super(UploadInitial()) {
    on<PickFromGallery>(_pickFromGallery);
    on<CaptureFromCamera>(_captureFromCamera);
  }

  Future<void> _pickFromGallery(PickFromGallery event, Emitter<UploadDocumentState> emit) async {
    emit(UploadInProgress());
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        emit(UploadSuccess(image));
      } else {
        emit(UploadFailure("No image selected"));
      }
    } catch (e) {
      emit(UploadFailure("Error picking image"));
    }
  }

  Future<void> _captureFromCamera(CaptureFromCamera event, Emitter<UploadDocumentState> emit) async {
    emit(UploadInProgress());
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        emit(UploadSuccess(image));
      } else {
        emit(UploadFailure("No image captured"));
      }
    } catch (e) {
      emit(UploadFailure("Error capturing image"));
    }
  }
}
