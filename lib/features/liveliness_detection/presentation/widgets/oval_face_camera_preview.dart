import 'dart:math';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/recording_state.dart';

class OvalFaceCameraPreview extends StatelessWidget {
  final CameraController controller;
  final RecordingState recordingState;
  final String? instruction;

  const OvalFaceCameraPreview({
    super.key,
    required this.controller,
    required this.recordingState,
    this.instruction,
  });

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Transform.scale(
          scaleX: -1,
          child: RotatedBox(
            quarterTurns: 3,
            child: CameraPreview(controller),
          ),
        ),
        CustomPaint(
          painter: OvalOverlayPainter(
            recordingState: recordingState,
            theme: Theme.of(context),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (recordingState != RecordingState.initial &&
                    recordingState != RecordingState.completed)
                  _buildArrowIndicator(context),
                if (instruction?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white24,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      instruction!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ).animate().fadeIn().scale(),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildArrowIndicator(BuildContext context) {
    IconData arrowIcon;
    double rotation = 0;

    switch (recordingState) {
      case RecordingState.lookUp:
        arrowIcon = Icons.arrow_upward_rounded;
        rotation = 0;
        break;
      case RecordingState.lookDown:
        arrowIcon = Icons.arrow_downward_rounded;
        rotation = 0;
        break;
      case RecordingState.lookLeft:
        arrowIcon = Icons.arrow_forward_rounded;
        rotation = 180;
        break;
      case RecordingState.lookRight:
        arrowIcon = Icons.arrow_forward_rounded;
        rotation = 0;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Transform.rotate(
      angle: rotation * 3.14159 / 180,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Icon(
          arrowIcon,
          color: Theme.of(context).colorScheme.primary,
          size: 48,
        ),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .scale(
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
        )
        .then()
        .scale(
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          begin: const Offset(1.2, 1.2),
          end: const Offset(1, 1),
        );
  }
}

class OvalOverlayPainter extends CustomPainter {
  final RecordingState recordingState;
  final ThemeData theme;

  OvalOverlayPainter({
    required this.recordingState,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black45
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );

    final ovalWidth = size.width * 0.85;
    final ovalHeight = size.height * 0.6;
    final ovalRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: ovalWidth,
      height: ovalHeight,
    );

    final path = Path()
      ..addOval(ovalRect)
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..color = _getBorderColor()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawOval(ovalRect, borderPaint);

    if (recordingState == RecordingState.initial) {
      final dashPaint = Paint()
        ..color = Colors.white30
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      _drawDashedOval(canvas, ovalRect.inflate(20), dashPaint);
    }
  }

  void _drawDashedOval(Canvas canvas, Rect rect, Paint paint) {
    final path = Path();
    final dashWidth = 10;
    final dashSpace = 5;
    double startAngle = 0;
    final sweepAngle = 360 * 3.14159 / 180;
    final centerX = rect.center.dx;
    final centerY = rect.center.dy;
    final radiusX = rect.width / 2;
    final radiusY = rect.height / 2;

    for (double i = 0; i < sweepAngle; i += (dashWidth + dashSpace) / radiusX) {
      final x1 = centerX + radiusX * cos(startAngle + i);
      final y1 = centerY + radiusY * sin(startAngle + i);
      final x2 = centerX + radiusX * cos(startAngle + i + dashWidth / radiusX);
      final y2 = centerY + radiusY * sin(startAngle + i + dashWidth / radiusX);

      path.moveTo(x1, y1);
      path.lineTo(x2, y2);
    }

    canvas.drawPath(path, paint);
  }

  Color _getBorderColor() {
    switch (recordingState) {
      case RecordingState.initial:
        return Colors.white;
      case RecordingState.completed:
        return theme.colorScheme.tertiary;
      case RecordingState.recording:
        return theme.colorScheme.primary;
      default:
        return theme.colorScheme.primary;
    }
  }

  @override
  bool shouldRepaint(OvalOverlayPainter oldDelegate) =>
      oldDelegate.recordingState != recordingState;
}
