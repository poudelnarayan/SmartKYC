import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'selfie_capture_event.dart';
import 'selfie_capture_state.dart';

class SelfieCaptureBloc extends Bloc<SelfieCaptureEvent, SelfieCaptureState> {
  final CameraController _cameraController;

  SelfieCaptureBloc(this._cameraController) : super(SelfieInitial()) {
    on<CaptureSelfie>(_onCaptureSelfie);
  }

  Future<void> _onCaptureSelfie(
      CaptureSelfie event, Emitter<SelfieCaptureState> emit) async {
    emit(SelfieCapturing());
    try {
      final XFile image = await _cameraController.takePicture();
      emit(SelfieCaptured(image));
    } catch (e) {
      emit(SelfieCaptureError("Failed to capture selfie"));
    }
  }
}
