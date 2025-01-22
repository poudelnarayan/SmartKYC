import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import '../bloc/selfie_capture_bloc.dart';
import '../bloc/selfie_capture_event.dart';
import '../bloc/selfie_capture_state.dart';
import '../widgets/oval_face_overlay.dart';
import 'package:get_it/get_it.dart';

class SelfieCapturePage extends StatefulWidget {
  final CameraDescription camera = GetIt.I<List<CameraDescription>>()[1];

  SelfieCapturePage({Key? key}) : super(key: key);

  @override
  _SelfieCapturePageState createState() => _SelfieCapturePageState();
}

class _SelfieCapturePageState extends State<SelfieCapturePage> {
  late CameraController _cameraController;
  bool _isCaptured = false;
  XFile? _capturedImage;

  @override
  void initState() {
    super.initState();
    _cameraController = CameraController(
      widget.camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      await _cameraController.initialize();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void _capturePhoto(BuildContext context) {
    context.read<SelfieCaptureBloc>().add(CaptureSelfie());
  }

  @override
  Widget build(BuildContext context) {
    print("##################");
    print(widget.camera);
    print("##################");

    if (!_cameraController.value.isInitialized) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BlocProvider(
      create: (context) => SelfieCaptureBloc(_cameraController),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              if (!_isCaptured)
                Container(
                  height: MediaQuery.of(context).size.height - 200,
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: CameraPreview(
                      _cameraController,
                      child: OvalFaceOverlay(),
                    ),
                  ),
                )
              else if (_capturedImage != null)
                Center(
                  child: Image.file(
                    File(_capturedImage!.path),
                    fit: BoxFit.cover,
                  ),
                )
              else
                Center(
                    child: Text("Failed to capture image",
                        style: TextStyle(fontSize: 18))),
              Align(
                alignment: Alignment.bottomCenter,
                child: BlocConsumer<SelfieCaptureBloc, SelfieCaptureState>(
                  listener: (context, state) {
                    if (state is SelfieCaptured) {
                      setState(() {
                        _isCaptured = true;
                        _capturedImage = state.image;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text("Selfie Captured Successfully!")),
                      );
                    } else if (state is SelfieCaptureError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );
                    }
                  },
                  builder: (context, state) {
                    return _isCaptured
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(20),
                                child: ElevatedButton(
                                  onPressed: () => _capturePhoto(context),
                                  child: Text("Retake Selfie"),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(20),
                                child: ElevatedButton(
                                  onPressed: () =>
                                      context.go('/liveliness-detection'),
                                  child: Text("Continue"),
                                ),
                              )
                            ],
                          )
                        : Padding(
                            padding: EdgeInsets.all(20),
                            child: ElevatedButton(
                              onPressed: () => _capturePhoto(context),
                              child: Text("Capture Selfie"),
                            ),
                          );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
