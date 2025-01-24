import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'upload_document_event.dart';
import 'upload_document_state.dart';

class UploadDocumentBloc
    extends Bloc<UploadDocumentEvent, UploadDocumentState> {
  final ImagePicker _picker = ImagePicker();

  UploadDocumentBloc() : super(UploadInitial()) {
    on<PickFromGallery>(_pickFromGallery);
    on<CaptureFromCamera>(_captureFromCamera);
    on<SetCapturedImage>(_setCapturedImage);
    on<ResetUpload>((event, emit) => emit(UploadInitial()));
  }

  Future<void> _pickFromGallery(
    PickFromGallery event,
    Emitter<UploadDocumentState> emit,
  ) async {
    try {
      emit(UploadInProgress());
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        emit(UploadSuccess(image));
      } else {
        emit(const UploadFailure('no_image_selected'));
      }
    } catch (e) {
      emit(UploadFailure('failed_to_pick_image: ${e.toString()}'));
    }
  }

  Future<void> _captureFromCamera(
    CaptureFromCamera event,
    Emitter<UploadDocumentState> emit,
  ) async {
    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        emit(const UploadFailure('camera_permission_denied'));
        return;
      }
      emit(UploadInProgress());
    } catch (e) {
      emit(const UploadFailure('failed_to_capture_image'));
    }
  }

  void _setCapturedImage(
    SetCapturedImage event,
    Emitter<UploadDocumentState> emit,
  ) {
    if (event.image.path.isNotEmpty) {
      emit(UploadSuccess(event.image));
    } else {
      emit(const UploadFailure('invalid_image_file'));
    }
  }
}
