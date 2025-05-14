import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/recording_state.dart';
import '../../domain/entities/liveness_verification.dart';

class FloatingInstruction extends StatelessWidget {
  final RecordingState recordingState;
  final int completedMovementsCount;

  const FloatingInstruction({
    super.key,
    required this.recordingState,
    required this.completedMovementsCount,
  });

  String get instructionText {
    switch (recordingState) {
      case RecordingState.lookUp:
        return 'Look Up Then Return to Center';
      case RecordingState.lookDown:
        return 'Look Down Then Return to Center';
      case RecordingState.lookLeft:
        return 'Turn Left Then Return to Center';
      case RecordingState.lookRight:
        return 'Turn Right Then Return to Center';
      case RecordingState.recording:
        return completedMovementsCount >= LivenessVerification.requiredMovements
            ? 'Great! Movements Completed'
            : '$completedMovementsCount of 4 movements completed';
      default:
        return 'Position Your Face in the Oval';
    }
  }

  IconData get instructionIcon {
    switch (recordingState) {
      case RecordingState.lookUp:
        return Icons.arrow_upward;
      case RecordingState.lookDown:
        return Icons.arrow_downward;
      case RecordingState.lookLeft:
        return Icons.arrow_back;
      case RecordingState.lookRight:
        return Icons.arrow_forward;
      case RecordingState.recording:
        return completedMovementsCount >= LivenessVerification.requiredMovements
            ? Icons.check_circle
            : Icons.center_focus_strong;
      default:
        return Icons.face;
    }
  }

  Color getIconColor(BuildContext context) {
    switch (recordingState) {
      case RecordingState.recording:
        return completedMovementsCount >= LivenessVerification.requiredMovements
            ? Colors.green
            : Colors.white;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: recordingState == RecordingState.recording &&
                  completedMovementsCount >=
                      LivenessVerification.requiredMovements
              ? Colors.green.withOpacity(0.5)
              : Colors.white10,
          width: recordingState == RecordingState.recording &&
                  completedMovementsCount >=
                      LivenessVerification.requiredMovements
              ? 2
              : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            instructionIcon,
            color: getIconColor(context),
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            instructionText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }
}
