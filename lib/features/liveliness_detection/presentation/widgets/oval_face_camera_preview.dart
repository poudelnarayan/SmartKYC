import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/recording_state.dart';

class OvalFaceCameraPreview extends StatelessWidget {
  final CameraController controller;
  final RecordingState recordingState;
  final String instruction;

  const OvalFaceCameraPreview({
    super.key,
    required this.controller,
    required this.recordingState,
    required this.instruction,
  });

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera preview with oval clip
        Transform.scale(
          scaleX: -1,
          child: RotatedBox(
            quarterTurns: 3,
            child: ClipPath(
              clipper: OvalClipper(),
              child: CameraPreview(controller),
            ),
          ),
        ),

        // Overlay with instructions
        CustomPaint(
          painter: OvalOverlayPainter(
            recordingState: recordingState,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Arrow indicator
                if (recordingState != RecordingState.initial &&
                    recordingState != RecordingState.completed)
                  _buildArrowIndicator(context)
                      .animate(
                        onPlay: (controller) => controller.repeat(),
                      )
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
                      ),

                const SizedBox(height: 16),

                // Instruction text
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    instruction,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ).animate().fadeIn().scale(),
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
          color: Colors.white24,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Icon(
          arrowIcon,
          color: Colors.white,
          size: 48,
        ),
      ),
    );
  }
}

class OvalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.addOval(Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.6,
      height: size.height * 0.7,
    ));
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class OvalOverlayPainter extends CustomPainter {
  final RecordingState recordingState;

  OvalOverlayPainter({required this.recordingState});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    // Draw full screen overlay
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );

    // Calculate oval dimensions
    final ovalWidth = size.width * 0.8;
    final ovalHeight = size.height * 0.7;
    final ovalRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: ovalWidth,
      height: ovalHeight,
    );

    // Create oval cutout
    final path = Path()
      ..addOval(ovalRect)
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Draw oval border
    final borderPaint = Paint()
      ..color = _getBorderColor()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawOval(ovalRect, borderPaint);
  }

  Color _getBorderColor() {
    switch (recordingState) {
      case RecordingState.initial:
        return Colors.white;
      case RecordingState.completed:
        return Colors.green;
      case RecordingState.recording:
        return Colors.blue;
      default:
        return Colors.white;
    }
  }

  @override
  bool shouldRepaint(OvalOverlayPainter oldDelegate) =>
      oldDelegate.recordingState != recordingState;
}
