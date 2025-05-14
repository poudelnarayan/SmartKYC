import 'dart:io';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:smartkyc/features/success/presentation/pages/verification_success_page.dart';
import 'package:smartkyc/features/user_profile/presentation/pages/user_profile_page.dart';
import '../../../../domain/usecases/update_user.dart';
import '../bloc/liveliness_bloc.dart';
import '../bloc/liveliness_state.dart';
import '../bloc/liveliness_event.dart';
import '../widgets/oval_face_camera_preview.dart';
import '../widgets/movement_indicator.dart';
import '../widgets/center_indicator.dart';
import '../widgets/floating_instruction.dart';
import '../../domain/entities/recording_state.dart';
import '../../domain/entities/liveness_verification.dart';

class LivenessDetectionPage extends StatefulWidget {
  const LivenessDetectionPage({super.key});
  static const pageName = "livenessDetection";

  @override
  State<LivenessDetectionPage> createState() => _LivenessDetectionPageState();
}

class _LivenessDetectionPageState extends State<LivenessDetectionPage>
    with WidgetsBindingObserver {
  CameraController? _controller;
  late FaceDetector _faceDetector;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  bool _isNavigating = false;
  double? _initialY;
  double? _initialX;
  Timer? _faceProcTimer;
  Map<String, bool> _movementInProgress = {
    'up': false,
    'down': false,
    'left': false,
    'right': false
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeFaceDetector();
    _initializeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (_controller != null) {
        _initializeCamera();
      }
    }
  }

  void _initializeFaceDetector() {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        enableTracking: true,
        performanceMode: FaceDetectorMode.accurate,
        minFaceSize: 0.15,
      ),
    );
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();
      if (mounted) {
        setState(() {
          _controller = controller;
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        _showError('Error initializing camera: $e');
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _startRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    _initialX = null;
    _initialY = null;
    _movementInProgress = {
      'up': false,
      'down': false,
      'left': false,
      'right': false
    };

    try {
      await _controller!.startVideoRecording();
      context.read<LivenessBloc>().add(StartDetectionProcess());
      _startFaceTracking();
    } catch (e) {
      _showError('Failed to start recording: $e');
    }
  }

  void _startFaceTracking() {
    _faceProcTimer?.cancel();
    _faceProcTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _processNextFrame();
    });
  }

  Future<void> _processNextFrame() async {
    if (_isProcessing ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      return;
    }

    _isProcessing = true;

    try {
      final XFile imageFile = await _controller!.takePicture();
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        final face = faces.first;
        final y = face.boundingBox.top + (face.boundingBox.height / 2);
        final x = face.boundingBox.left + (face.boundingBox.width / 2);

        if (_initialY == null || _initialX == null) {
          _initialY = y;
          _initialX = x;
        } else {
          _checkMovement(y, x, context.read<LivenessBloc>());
        }
      }

      await File(imageFile.path).delete();
    } catch (e) {
      debugPrint("Error processing image: $e");
    } finally {
      _isProcessing = false;
    }
  }

  void _checkMovement(double y, double x, LivenessBloc bloc) {
    const threshold = 30.0;
    final state = bloc.state.recordingState;

    switch (state) {
      case RecordingState.lookUp:
        if (y < _initialY! - threshold && !_movementInProgress['up']!) {
          _movementInProgress['up'] = true;
          bloc
            ..add(const UpdateMovementStatus(movement: 'up', completed: true))
            ..add(AutoCompleteMovement());
        }
        break;
      case RecordingState.lookDown:
        if (y > _initialY! + threshold && !_movementInProgress['down']!) {
          _movementInProgress['down'] = true;
          bloc
            ..add(const UpdateMovementStatus(movement: 'down', completed: true))
            ..add(AutoCompleteMovement());
        }
        break;
      case RecordingState.lookLeft:
        if (x < _initialX! - threshold && !_movementInProgress['left']!) {
          _movementInProgress['left'] = true;
          bloc
            ..add(const UpdateMovementStatus(movement: 'left', completed: true))
            ..add(AutoCompleteMovement());
        }
        break;
      case RecordingState.lookRight:
        if (x > _initialX! + threshold && !_movementInProgress['right']!) {
          _movementInProgress['right'] = true;
          bloc
            ..add(
                const UpdateMovementStatus(movement: 'right', completed: true))
            ..add(AutoCompleteMovement());
        }
        break;
      default:
        break;
    }
  }

  Future<void> _stopAndUploadRecording(BuildContext context) async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isNavigating) {
      return;
    }

    _isNavigating = true;
    _faceProcTimer?.cancel();
    final bloc = context.read<LivenessBloc>();

    if (!bloc.state.hasCompletedRequiredMovements) {
      bloc.add(SetVerificationFailed());
      try {
        final video = await _controller!.stopVideoRecording();
        await File(video.path).delete();
      } catch (e) {
        debugPrint("Error stopping recording: $e");
      }
      _isNavigating = false;
      return;
    }

    bloc.add(const SetProcessingStatus(true));

    try {
      final video = await _controller!.stopVideoRecording();
      final videoFile = File(video.path);
      await videoFile.delete();

      await UpdateUser().verifySelfie(
        FirebaseAuth.instance.currentUser!.uid,
        'isLivenessVerified',
        true,
      );

      bloc.add(const SetProcessingStatus(false));

      if (mounted) {
        final extraData = GoRouterState.of(context).extra;
        final bool returnToProfile = (extraData is Map<String, dynamic>)
            ? (extraData['returnToProfile'] ?? false)
            : false;

        if (returnToProfile) {
          context.go(UserProfilePage.pageName);
        } else {
          context.go(VerificationSuccessPage.pageName);
        }
      }
    } catch (e) {
      bloc.add(const SetProcessingStatus(false));
      _isNavigating = false;
      if (mounted) {
        _showError('Failed to upload video: $e');
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _faceProcTimer?.cancel();
    _controller?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LivenessBloc, LivenessState>(
      listener: (context, state) async {
        if (state.recordingState == RecordingState.completed &&
            !_isNavigating) {
          await _stopAndUploadRecording(context);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              _buildBackground(context),
              if (_isCameraInitialized && _controller != null)
                Positioned.fill(
                  child: OvalFaceCameraPreview(
                    controller: _controller!,
                    recordingState: state.recordingState,
                    instruction: '',
                  ),
                ),
              if (!_isCameraInitialized) _buildLoadingIndicator(),
              if (state.isRecording) ...[
                _buildDirectionalIndicators(state),
                Positioned(
                  bottom: 70,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: FloatingInstruction(
                      recordingState: state.recordingState,
                      completedMovementsCount: state.completedMovementsCount,
                    ),
                  ),
                ),
              ],
              SafeArea(
                child: _buildTopBar(context, state),
              ),
              if (state.isVerificationFailed)
                _buildVerificationFailure(context),
              if (state.isProcessing) _buildProcessingOverlay(),
              if (!state.isProcessing && !state.isVerificationFailed)
                _buildActionButton(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackground(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Initializing Camera',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectionalIndicators(LivenessState state) {
    return Stack(
      children: [
        Center(
          child: CenterIndicator(
            recordingState: state.recordingState,
            isHoldingStill: state.recordingState == RecordingState.recording,
          ),
        ),
        Positioned(
          top: 180,
          left: 0,
          right: 0,
          child: Center(
            child: MovementIndicator(
              direction: 'up',
              icon: Icons.keyboard_arrow_up_rounded,
              completed: state.completedMovements['up']!,
              active: state.recordingState == RecordingState.lookUp,
            ),
          ),
        ),
        Positioned(
          bottom: 180,
          left: 0,
          right: 0,
          child: Center(
            child: MovementIndicator(
              direction: 'down',
              icon: Icons.keyboard_arrow_down_rounded,
              completed: state.completedMovements['down']!,
              active: state.recordingState == RecordingState.lookDown,
            ),
          ),
        ),
        Positioned(
          left: 40,
          top: 0,
          bottom: 0,
          child: Center(
            child: MovementIndicator(
              direction: 'left',
              icon: Icons.keyboard_arrow_left_rounded,
              completed: state.completedMovements['left']!,
              active: state.recordingState == RecordingState.lookLeft,
            ),
          ),
        ),
        Positioned(
          right: 40,
          top: 0,
          bottom: 0,
          child: Center(
            child: MovementIndicator(
              direction: 'right',
              icon: Icons.keyboard_arrow_right_rounded,
              completed: state.completedMovements['right']!,
              active: state.recordingState == RecordingState.lookRight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context, LivenessState state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),
          const Spacer(),
          if (state.isRecording)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Recording',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .fadeOut(duration: const Duration(milliseconds: 700))
                .fadeIn(duration: const Duration(milliseconds: 700)),
        ],
      ),
    );
  }

  Widget _buildVerificationFailure(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  color: Theme.of(context).colorScheme.error,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Verification Failed',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Please complete at least ${LivenessVerification.requiredMovements} different head movements during the verification process.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    context.read<LivenessBloc>().add(ResetVerification());
                    _startRecording();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Try Again',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn().scale(),
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.9),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  strokeWidth: 8,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Processing Video',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please wait while we verify your identity',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ).animate().fadeIn().scale(),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, LivenessState state) {
    if (state.recordingState == RecordingState.initial) {
      return Positioned(
        bottom: 40,
        left: 0,
        right: 0,
        child: Center(
          child: FilledButton.icon(
            onPressed: _startRecording,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Start Verification'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 20,
              ),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ).animate().fadeIn().scale(),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
