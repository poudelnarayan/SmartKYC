import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameraController = CameraController(
        widget.camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
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

  Future<void> _navigateToLiveliness(BuildContext context) async {
    await _cameraController.dispose();
    if (mounted) {
      context.go('/liveliness-detection-start');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (!_cameraController.value.isInitialized) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    return BlocProvider(
      create: (context) => SelfieCaptureBloc(_cameraController),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 180, 206, 249),
        appBar: _isCaptured
            ? AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onPressed: () => setState(() {
                    _isCaptured = false;
                    _capturedImage = null;
                  }),
                ),
                title: Text(
                  l10n.reviewSelfie,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : null,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (!_isCaptured)
                      Transform.scale(
                        scaleX: -1,
                        child: SizedBox(
                          width: double.infinity,
                          height: 500,
                          child: AspectRatio(
                            aspectRatio: _cameraController.value.aspectRatio,
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: CameraPreview(
                                _cameraController,
                                child: OvalFaceOverlay(),
                              ),
                            ),
                          ),
                        ),
                      )
                    else if (_capturedImage != null)
                      Transform.scale(
                        scaleX: -1,
                        child: SizedBox(
                          width: double.infinity,
                          child: Image.file(
                            File(_capturedImage!.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      Center(
                        child: Text(
                          l10n.captureError,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    if (!_isCaptured)
                      Positioned(
                        top: 16,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            l10n.positionFace,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color.fromARGB(173, 42, 40, 41),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                color: const Color.fromARGB(255, 180, 206, 249),
                padding: const EdgeInsets.all(24),
                child: BlocConsumer<SelfieCaptureBloc, SelfieCaptureState>(
                  listener: (context, state) {
                    if (state is SelfieCaptured) {
                      setState(() {
                        _isCaptured = true;
                        _capturedImage = state.image;
                      });
                    } else if (state is SelfieCaptureError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is SelfieCaptureInProgress) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    }

                    return _isCaptured
                        ? Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _isCaptured = false;
                                      _capturedImage = null;
                                    });
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: Text(l10n.retake),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(color: Colors.white),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () =>
                                      _navigateToLiveliness(context),
                                  icon: const Icon(Icons.check),
                                  label: Text(l10n.continue_operation),
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Center(
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: IconButton(
                                onPressed: () => _capturePhoto(context),
                                icon: Icon(
                                  Icons.camera,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 32,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding: const EdgeInsets.all(16),
                                ),
                              ),
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
