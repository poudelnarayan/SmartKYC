import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/recording_state.dart';
import './liveliness_event.dart';
import './liveliness_state.dart';

class LivenessBloc extends Bloc<LivenessEvent, LivenessState> {
  Timer? _stateTimer;
  Timer? _recordingTimer;
  static const _movementDuration = Duration(seconds: 3);
  static const _totalDuration = Duration(seconds: 15);

  LivenessBloc() : super(LivenessState.initial()) {
    on<StartDetectionProcess>(_onStartDetectionProcess);
    on<AutoCompleteMovement>(_onAutoCompleteMovement);
    on<UpdateRecordingDuration>(_onUpdateRecordingDuration);
    on<CompleteDetection>(_onCompleteDetection);
  }

  void _onStartDetectionProcess(
    StartDetectionProcess event,
    Emitter<LivenessState> emit,
  ) {
    emit(state.copyWith(
      recordingState: RecordingState.lookUp,
      instruction: 'Please look up slowly',
      isRecording: true,
    ));

    _startStateTimer();
    _startRecordingTimer();
  }

  void _startStateTimer() {
    _stateTimer?.cancel();
    _stateTimer = Timer.periodic(_movementDuration, (timer) {
      if (!isClosed) {
        add(AutoCompleteMovement());
      }
    });
  }

  void _startRecordingTimer() {
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isClosed) {
        add(UpdateRecordingDuration());
      }
    });

    Future.delayed(_totalDuration, () {
      if (!isClosed) {
        add(CompleteDetection());
      }
    });
  }

  void _onAutoCompleteMovement(
    AutoCompleteMovement event,
    Emitter<LivenessState> emit,
  ) {
    switch (state.recordingState) {
      case RecordingState.lookUp:
        emit(state.copyWith(
          recordingState: RecordingState.lookDown,
          instruction: 'Now look down slowly',
        ));
        break;
      case RecordingState.lookDown:
        emit(state.copyWith(
          recordingState: RecordingState.lookLeft,
          instruction: 'Turn your head to the left',
        ));
        break;
      case RecordingState.lookLeft:
        emit(state.copyWith(
          recordingState: RecordingState.lookRight,
          instruction: 'Finally, turn to the right',
        ));
        break;
      case RecordingState.lookRight:
        emit(state.copyWith(
          recordingState: RecordingState.recording,
          instruction: 'Great! Keep your head centered',
        ));
        break;
      default:
        break;
    }
  }

  void _onUpdateRecordingDuration(
    UpdateRecordingDuration event,
    Emitter<LivenessState> emit,
  ) {
    final newDuration =
        Duration(seconds: state.recordingDuration.inSeconds + 1);
    emit(state.copyWith(recordingDuration: newDuration));
  }

  void _onCompleteDetection(
    CompleteDetection event,
    Emitter<LivenessState> emit,
  ) {
    _stateTimer?.cancel();
    _recordingTimer?.cancel();
    emit(state.copyWith(
      recordingState: RecordingState.completed,
      isRecording: false,
      instruction: '',
    ));
  }

  @override
  Future<void> close() {
    _stateTimer?.cancel();
    _recordingTimer?.cancel();
    return super.close();
  }
}
