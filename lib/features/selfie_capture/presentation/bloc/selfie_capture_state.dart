import 'package:camera/camera.dart';

abstract class SelfieCaptureState {}

class SelfieCaptureInitial extends SelfieCaptureState {}

class SelfieCaptureInProgress extends SelfieCaptureState {}

class SelfieCaptured extends SelfieCaptureState {
  final XFile image;

  SelfieCaptured(this.image);
}

class SelfieCaptureError extends SelfieCaptureState {
  final String message;

  SelfieCaptureError(this.message);
}