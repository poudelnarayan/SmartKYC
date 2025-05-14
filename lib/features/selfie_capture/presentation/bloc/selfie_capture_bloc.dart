import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'selfie_capture_event.dart';
import 'selfie_capture_state.dart';


class SelfieCaptureBloc extends Bloc<SelfieCaptureEvent, SelfieCaptureState> {
  final CameraController cameraController;

  SelfieCaptureBloc(this.cameraController) : super(SelfieCaptureInitial()) {
    on<CaptureSelfie>(_onCaptureSelfie);
  }

  Future<void> _onCaptureSelfie(
    CaptureSelfie event,
    Emitter<SelfieCaptureState> emit,
  ) async {
    try {
      emit(SelfieCaptureInProgress());
      
      final XFile image = await cameraController.takePicture();
      emit(SelfieCaptured(image));
    } catch (e) {
      emit(SelfieCaptureError('Failed to capture selfie: ${e.toString()}'));
    }
  }
}
