import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/recording_state.dart';

class CenterIndicator extends StatelessWidget {
  final RecordingState recordingState;
  final bool isHoldingStill;

  const CenterIndicator({
    super.key,
    required this.recordingState,
    required this.isHoldingStill,
  });

  @override
  Widget build(BuildContext context) {
    if (recordingState == RecordingState.lookUp ||
        recordingState == RecordingState.lookDown ||
        recordingState == RecordingState.lookLeft ||
        recordingState == RecordingState.lookRight) {
      return const SizedBox.shrink();
    }

    return Opacity(
      opacity: isHoldingStill ? 0.9 : 0.5,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isHoldingStill
              ? Colors.green.withOpacity(0.2)
              : Colors.white.withOpacity(0.1),
          border: Border.all(
            color:
                isHoldingStill ? Colors.green : Colors.white.withOpacity(0.6),
            width: 2,
          ),
        ),
        child: Icon(
          isHoldingStill ? Icons.center_focus_strong : Icons.face,
          color: isHoldingStill ? Colors.green : Colors.white,
          size: 40,
        ),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .fadeOut(begin: 1.0, duration: const Duration(milliseconds: 1000))
        .fadeIn(begin: 0.7, duration: const Duration(milliseconds: 1000));
  }
}
