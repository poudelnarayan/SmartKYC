import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'upload_document_event.dart';
import 'upload_document_state.dart';

class UploadDocumentBloc
    extends Bloc<UploadDocumentEvent, UploadDocumentState> {
  final ImagePicker _picker = ImagePicker();

  UploadDocumentBloc() : super(DocumentPreviewInitial()) {
    on<PickFromGallery>(_pickFromGallery);
    on<CaptureFromCamera>(_captureFromCamera);
    on<SetCapturedImage>(_setCapturedImage);
    on<ResetUpload>((event, emit) => emit(DocumentPreviewInitial()));
  }

  Future<void> _pickFromGallery(
    PickFromGallery event,
    Emitter<UploadDocumentState> emit,
  ) async {
    try {
      emit(DocumentPreviewInProgress());
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        emit(DocumentPreviewSuccess(image));
      } else {
        emit(DocumentPreviewFailure('no_image_selected'));
      }
    } catch (e) {
      emit(DocumentPreviewFailure('failed_to_pick_image: ${e.toString()}'));
    }
  }

  Future<void> _captureFromCamera(
    CaptureFromCamera event,
    Emitter<UploadDocumentState> emit,
  ) async {
    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        emit(DocumentPreviewFailure('camera_permission_denied'));
        return;
      }
      emit(DocumentPreviewInProgress());
    } catch (e) {
      emit(DocumentPreviewFailure('failed_to_capture_image'));
    }
  }

  void _setCapturedImage(
    SetCapturedImage event,
    Emitter<UploadDocumentState> emit,
  ) {
    if (event.image.path.isNotEmpty) {
      emit(DocumentPreviewSuccess(event.image));
    } else { 
      emit(DocumentPreviewFailure('invalid_image_file'));
    }
  }
}
