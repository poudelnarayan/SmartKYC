import 'package:equatable/equatable.dart';
import '../../domain/entities/recording_state.dart';
import '../../domain/entities/liveness_verification.dart';

class LivenessState extends Equatable {
  final RecordingState recordingState;
  final String? videoPath;
  final String instruction;
  final bool isRecording;
  final Duration recordingDuration;
  final bool isProcessing;
  final bool isVerificationFailed;
  final Map<String, bool> completedMovements;

  const LivenessState({
    required this.recordingState,
    this.videoPath,
    required this.instruction,
    required this.isRecording,
    required this.recordingDuration,
    this.isProcessing = false,
    this.isVerificationFailed = false,
    this.completedMovements = const {
      'up': false,
      'down': false,
      'left': false,
      'right': false,
    },
  });

  factory LivenessState.initial() {
    return const LivenessState(
      recordingState: RecordingState.initial,
      instruction: 'Position your face within the oval and press start',
      isRecording: false,
      recordingDuration: Duration.zero,
    );
  }

  LivenessState copyWith({
    RecordingState? recordingState,
    String? videoPath,
    String? instruction,
    bool? isRecording,
    Duration? recordingDuration,
    bool? isProcessing,
    bool? isVerificationFailed,
    Map<String, bool>? completedMovements,
  }) {
    return LivenessState(
      recordingState: recordingState ?? this.recordingState,
      videoPath: videoPath ?? this.videoPath,
      instruction: instruction ?? this.instruction,
      isRecording: isRecording ?? this.isRecording,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      isProcessing: isProcessing ?? this.isProcessing,
      isVerificationFailed: isVerificationFailed ?? this.isVerificationFailed,
      completedMovements: completedMovements ?? this.completedMovements,
    );
  }

  int get completedMovementsCount =>
      completedMovements.values.where((completed) => completed).length;

  bool get hasCompletedRequiredMovements =>
      completedMovementsCount >= LivenessVerification.requiredMovements;

  @override
  List<Object?> get props => [
        recordingState,
        videoPath,
        instruction,
        isRecording,
        recordingDuration,
        isProcessing,
        isVerificationFailed,
        completedMovements,
      ];
}
