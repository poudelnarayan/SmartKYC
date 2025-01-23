import 'package:equatable/equatable.dart';
import '../../domain/entities/recording_state.dart';

class LivenessState extends Equatable {
  final RecordingState recordingState;
  final String? videoPath;
  final String instruction;
  final bool isRecording;
  final Duration recordingDuration;

  const LivenessState({
    required this.recordingState,
    this.videoPath,
    required this.instruction,
    required this.isRecording,
    required this.recordingDuration,
  });

  factory LivenessState.initial() {
    return const LivenessState(
      recordingState: RecordingState.initial,
      instruction: 'Press start to begin liveness detection',
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
  }) {
    return LivenessState(
      recordingState: recordingState ?? this.recordingState,
      videoPath: videoPath ?? this.videoPath,
      instruction: instruction ?? this.instruction,
      isRecording: isRecording ?? this.isRecording,
      recordingDuration: recordingDuration ?? this.recordingDuration,
    );
  }

  @override
  List<Object?> get props => [
        recordingState,
        videoPath,
        instruction,
        isRecording,
        recordingDuration,
      ];
}
