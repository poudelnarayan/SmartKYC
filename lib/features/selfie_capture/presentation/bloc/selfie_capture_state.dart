import 'package:equatable/equatable.dart';
import 'package:camera/camera.dart';

abstract class SelfieCaptureState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SelfieInitial extends SelfieCaptureState {}

class SelfieCapturing extends SelfieCaptureState {}

class SelfieCaptured extends SelfieCaptureState {
  final XFile image;
  SelfieCaptured(this.image);

  @override
  List<Object?> get props => [image];
}

class SelfieCaptureError extends SelfieCaptureState {
  final String message;
  SelfieCaptureError(this.message);

  @override
  List<Object?> get props => [message];
}
