import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class OvalFaceCameraPreview extends StatelessWidget {
  final CameraController controller;

  const OvalFaceCameraPreview({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }

    return Transform.scale(
      scaleX: -1,
      child: ClipPath(
        clipper: OvalClipper(),
        child: SizedBox(
          height: 500,
          width: 400,
          child: RotatedBox(
            quarterTurns: 3,
            child: CameraPreview(controller),
          ),
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
      width: size.width * 0.8,
      height: size.height * 0.8,
    ));
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
