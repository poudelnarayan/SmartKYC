import 'package:equatable/equatable.dart';

abstract class LivenessEvent extends Equatable {
  const LivenessEvent();

  @override
  List<Object> get props => [];
}

class StartDetectionProcess extends LivenessEvent {}

class AutoCompleteMovement extends LivenessEvent {}

class UpdateRecordingDuration extends LivenessEvent {}

class CompleteDetection extends LivenessEvent {}
