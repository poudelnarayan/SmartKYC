import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class DocumentCameraPage extends StatefulWidget {
  const DocumentCameraPage({super.key});

  static const pageName = "captureDocument";

  @override
  State<DocumentCameraPage> createState() => _DocumentCameraPageState();
}

class _DocumentCameraPageState extends State<DocumentCameraPage> {
  CameraController? _controller;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    final controller = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
    );

    try {
      await controller.initialize();
      if (mounted) {
        setState(() {
          _controller = controller;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error initializing camera: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final image = await _controller!.takePicture();
      if (mounted) {
        Navigator.pop(context, image);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error capturing image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: 190,
              left: 32,
              child: SizedBox(
                width: size.width * 0.85,
                height: size.height * 0.50,
                child: RotatedBox(
                  quarterTurns: 1,
                  child: CameraPreview(_controller!),
                ),
              ),
            ),
            CustomPaint(
              painter: DocumentFramePainter(),
            ),

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                color: Colors.black45,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Scan Document',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),

            Positioned(
              top: 120,
              left: 24,
              right: 24,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Position your document within the frame',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            // Capture Button
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color.fromARGB(255, 180, 206, 249),
                      width: 3,
                    ),
                  ),
                  child: IconButton(
                    onPressed: _captureImage,
                    icon: const Icon(
                      Icons.camera_alt,
                      size: 40,
                      color: Color.fromARGB(255, 180, 206, 249),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DocumentFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 180, 206, 249)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Calculate rectangle dimensions
    final rectWidth = size.width * 0.85;
    final rectHeight =
        size.width * 0.55; // Using width to maintain aspect ratio

    // Semi-transparent overlay
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..addRect(Rect.fromCenter(
            center: Offset(size.width / 2, size.height / 2),
            width: rectWidth,
            height: rectHeight * 2,
          )),
      ),
      Paint()..color = Colors.black54,
    );

    // Rectangle frame
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: rectWidth,
      height: rectHeight * 2,
    );
    canvas.drawRect(rect, paint);

    // Corner indicators
    final cornerLength = rectWidth * 0.1;
    final cornerPaint = Paint()
      ..color = const Color.fromARGB(255, 180, 206, 249)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    // Draw corners
    void drawCorner(Offset start, bool isHorizontal) {
      final end = isHorizontal
          ? start.translate(cornerLength, 0)
          : start.translate(0, cornerLength);
      canvas.drawLine(start, end, cornerPaint);
    }

    // Top-left corners
    drawCorner(rect.topLeft, true);
    drawCorner(rect.topLeft, false);

    // Top-right corners
    drawCorner(rect.topRight.translate(-cornerLength, 0), true);
    drawCorner(rect.topRight, false);

    // Bottom-left corners
    drawCorner(rect.bottomLeft.translate(0, -cornerLength), false);
    drawCorner(rect.bottomLeft, true);

    // Bottom-right corners
    drawCorner(rect.bottomRight.translate(-cornerLength, 0), true);
    drawCorner(rect.bottomRight.translate(0, -cornerLength), false);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
