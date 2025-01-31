import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smartkyc/domain/usecases/update_user.dart';
import 'package:smartkyc/features/liveliness_detection/presentation/pages/liveness_detection_start_page.dart';
import '../../../../core/services/storage_service.dart';
import '../../../verification_steps/presentation/widgets/verification_progress_overlay.dart';
import '../bloc/selfie_capture_bloc.dart';
import '../bloc/selfie_capture_event.dart';
import '../bloc/selfie_capture_state.dart';
import '../widgets/oval_face_overlay.dart';
import 'package:get_it/get_it.dart';

class SelfieCapturePage extends StatefulWidget {
  final CameraDescription camera = GetIt.I<List<CameraDescription>>()[1];

  static const pageName = "selfieCapture";

  SelfieCapturePage({Key? key}) : super(key: key);

  @override
  _SelfieCapturePageState createState() => _SelfieCapturePageState();
}

class _SelfieCapturePageState extends State<SelfieCapturePage> {
  late CameraController _cameraController;
  bool _isCaptured = false;
  bool _isUploading = false;
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
      if (mounted) setState(() {});
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

  Future<void> _handleUploadAndNavigate(
      BuildContext context, XFile image) async {
    setState(() {
      _isUploading = true;
    });

    try {
      final storageService = StorageService();
      final downloadUrl = await storageService.uploadSelfie(File(image.path));
      // await UpdateUser().verifySelfie();
      print('Selfie uploaded successfully: $downloadUrl');

      if (mounted) {
        await _navigateToLiveliness(context);
      }
    } catch (e) {
      print('Error uploading selfie: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload selfie: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _navigateToLiveliness(BuildContext context) async {
    await _cameraController.dispose();
    if (mounted) {
      Navigator.push(
        context,
        PageRouteBuilder(
          opaque: true,
          pageBuilder: (context, _, __) => VerificationProgressOverlay(
            completedStep: 2,
            nextRoute: LivenessDetectionStartPage.pageName,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (!_cameraController.value.isInitialized) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
        ),
      );
    }

    return BlocProvider(
      create: (context) => SelfieCaptureBloc(_cameraController),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: BlocConsumer<SelfieCaptureBloc, SelfieCaptureState>(
          listener: (context, state) async {
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
            return SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        // Camera Preview or Captured Image
                        Positioned.fill(
                          child: !_isCaptured
                              ? Container(
                                  color: Colors.black,
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                    child: SizedBox(
                                      width: _cameraController
                                          .value.previewSize!.height,
                                      height: _cameraController
                                          .value.previewSize!.width,
                                      child: RotatedBox(
                                        quarterTurns: 1, // 90 degrees
                                        child: Transform.scale(
                                          scaleX: -1, // Mirror effect
                                          child: CameraPreview(
                                            _cameraController,
                                            child: Stack(
                                              children: [
                                                OvalFaceOverlay(),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Transform.scale(
                                  scaleX: -1,
                                  child: Image.file(
                                    File(_capturedImage!.path),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),

                        // Top Bar
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: () => context.pop(),
                                  icon: const Icon(Icons.close,
                                      color: Colors.white),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.black26,
                                  ),
                                ),
                                if (_isCaptured)
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.black54,
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Text(
                                        l10n.reviewSelfie,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        // Bottom Controls
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black87,
                                  Colors.black54,
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: SafeArea(
                              child: state is SelfieCaptureInProgress
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    )
                                  : _isCaptured
                                      ? Row(
                                          children: [
                                            if (!_isUploading)
                                              Expanded(
                                                child: OutlinedButton.icon(
                                                  onPressed: _isUploading
                                                      ? null
                                                      : () {
                                                          setState(() {
                                                            _isCaptured = false;
                                                            _capturedImage =
                                                                null;
                                                          });
                                                        },
                                                  icon:
                                                      const Icon(Icons.refresh),
                                                  label: Text(l10n.retake),
                                                  style:
                                                      OutlinedButton.styleFrom(
                                                    foregroundColor:
                                                        Colors.white,
                                                    side: BorderSide(
                                                      color: _isUploading
                                                          ? Colors.white38
                                                          : Colors.white,
                                                    ),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      vertical: 16,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: FilledButton.icon(
                                                onPressed: _isUploading
                                                    ? () {}
                                                    : () =>
                                                        _handleUploadAndNavigate(
                                                            context,
                                                            _capturedImage!),
                                                icon: _isUploading
                                                    ? Container(
                                                        width: 24,
                                                        height: 24,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2),
                                                        child:
                                                            const CircularProgressIndicator(
                                                          color: Colors.blue,
                                                          strokeWidth: 3,
                                                        ),
                                                      )
                                                    : const Icon(
                                                        Icons.check,
                                                        color: Colors.blue,
                                                      ),
                                                label: Text(
                                                  _isUploading
                                                      ? l10n.pleaseWait
                                                      : l10n.continue_operation,
                                                ),
                                                style: FilledButton.styleFrom(
                                                  backgroundColor: Colors.white,
                                                  foregroundColor:
                                                      theme.colorScheme.primary,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ).animate().fadeIn().slideY()
                                      : Center(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.white
                                                      .withOpacity(0.2),
                                                  blurRadius: 16,
                                                  spreadRadius: 4,
                                                ),
                                              ],
                                            ),
                                            padding: const EdgeInsets.all(4),
                                            child: IconButton(
                                              onPressed: () =>
                                                  _capturePhoto(context),
                                              icon: Icon(
                                                Icons.camera,
                                                color:
                                                    theme.colorScheme.primary,
                                                size: 32,
                                              ),
                                              style: IconButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.all(16),
                                              ),
                                            ),
                                          ),
                                        ).animate().fadeIn().scale(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
