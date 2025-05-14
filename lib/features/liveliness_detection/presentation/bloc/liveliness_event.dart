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

class UpdateMovementStatus extends LivenessEvent {
  final String movement;
  final bool completed;

  const UpdateMovementStatus({
    required this.movement,
    required this.completed,
  });

  @override
  List<Object> get props => [movement, completed];
}

class SetVerificationFailed extends LivenessEvent {}

class ResetVerification extends LivenessEvent {}

class SetProcessingStatus extends LivenessEvent {
  final bool isProcessing;

  const SetProcessingStatus(this.isProcessing);

  @override
  List<Object> get props => [isProcessing];
}
