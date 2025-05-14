import 'package:equatable/equatable.dart';

abstract class SelfieCaptureEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CaptureSelfie extends SelfieCaptureEvent {}
