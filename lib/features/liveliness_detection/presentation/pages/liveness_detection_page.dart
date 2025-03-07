import 'dart:io';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:smartkyc/features/success/presentation/pages/verification_success_page.dart';
import 'package:smartkyc/features/user_profile/presentation/pages/user_profile_page.dart';
import '../../../../domain/usecases/update_user.dart';
import '../bloc/liveliness_bloc.dart';
import '../bloc/liveliness_state.dart';
import '../bloc/liveliness_event.dart';
import '../widgets/oval_face_camera_preview.dart';
import '../../domain/entities/recording_state.dart';
import '../../../../core/services/storage_service.dart';

class LivenessDetectionPage extends StatefulWidget {
  const LivenessDetectionPage({super.key});
  static const pageName = "livenessDetection";

  @override
  State<LivenessDetectionPage> createState() => _LivenessDetectionPageState();
}

class _LivenessDetectionPageState extends State<LivenessDetectionPage> {
  CameraController? _controller;
  late FaceDetector _faceDetector;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  bool _isUploading = false;
  bool _verificationFailed = false;
  double? _lastY;
  double? _lastX;
  Timer? _faceProcTimer;
  XFile? _recordedVideo;

  // Track which movements have been completed
  final Map<String, bool> _completedMovements = {
    'up': false,
    'down': false,
    'left': false,
    'right': false
  };

  int get _completedMovementsCount =>
      _completedMovements.values.where((completed) => completed).length;

  @override
  void initState() {
    super.initState();
    _initializeFaceDetector();
    _initializeCamera();
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing camera: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _startRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() {
      _verificationFailed = false;
      _completedMovements.updateAll((key, value) => false);
    });

    try {
      await _controller!.startVideoRecording();
      context.read<LivenessBloc>().add(StartDetectionProcess());

      // Start face tracking after recording begins
      _startFaceTracking();
    } catch (e) {
      print('Error starting recording: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start recording: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _startFaceTracking() {
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
      // Capture an image for processing
      final XFile imageFile = await _controller!.takePicture();

      // Process the image file with ML Kit
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        final face = faces.first;

        final y = face.boundingBox.top + (face.boundingBox.height / 2);
        final x = face.boundingBox.left + (face.boundingBox.width / 2);

        final bloc = context.read<LivenessBloc>();
        final currentState = bloc.state.recordingState;

        if (_lastY != null && _lastX != null) {
          // Check movements based on current state
          if (y < _lastY! - 15) {
            // Looking up
            setState(() {
              _completedMovements['up'] = true;
            });

            if (currentState == RecordingState.lookUp) {
              // Advance to next instruction with a small delay for feedback
              Future.delayed(const Duration(milliseconds: 300), () {
                bloc.add(AutoCompleteMovement());
              });
            }
          } else if (y > _lastY! + 15) {
            // Looking down
            setState(() {
              _completedMovements['down'] = true;
            });

            if (currentState == RecordingState.lookDown) {
              // Advance to next instruction with a small delay for feedback
              Future.delayed(const Duration(milliseconds: 300), () {
                bloc.add(AutoCompleteMovement());
              });
            }
          } else if (x < _lastX! - 15) {
            // Looking left
            setState(() {
              _completedMovements['left'] = true;
            });

            if (currentState == RecordingState.lookLeft) {
              // Advance to next instruction with a small delay for feedback
              Future.delayed(const Duration(milliseconds: 300), () {
                bloc.add(AutoCompleteMovement());
              });
            }
          } else if (x > _lastX! + 15) {
            // Looking right
            setState(() {
              _completedMovements['right'] = true;
            });

            if (currentState == RecordingState.lookRight) {
              // Advance to next instruction with a small delay for feedback
              Future.delayed(const Duration(milliseconds: 300), () {
                bloc.add(AutoCompleteMovement());
              });
            }
          }
        }

        _lastY = y;
        _lastX = x;
      } else {
        // Reset position tracking when face is lost
        _lastY = null;
        _lastX = null;
      }

      // Delete the temporary file
      await File(imageFile.path).delete();
    } catch (e) {
      print("Error processing image: $e");
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _stopAndUploadRecording(BuildContext context) async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    // Cancel face processing timer
    _faceProcTimer?.cancel();

    // Check if at least two movements were completed
    if (_completedMovementsCount < 2) {
      setState(() {
        _verificationFailed = true;
      });

      // Stop recording but don't upload
      try {
        final video = await _controller!.stopVideoRecording();
        await File(video.path).delete(); // Cleanup
      } catch (e) {
        print("Error stopping recording: $e");
      }

      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final video = await _controller!.stopVideoRecording();
      _recordedVideo = video;

      // Create a new file with .mp4 extension
      final videoFile = File(video.path);
      final directory = await videoFile.parent.create(recursive: true);
      final newPath =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';
      await videoFile.copy(newPath);
      await videoFile.delete(); // Delete the original temp file

      final storageService = StorageService();
      final downloadUrl =
          await storageService.uploadLivenessVideo(File(newPath));
      print('Liveness video uploaded successfully: $downloadUrl');

      await File(newPath).delete();
      await UpdateUser().verifySelfie(
        FirebaseAuth.instance.currentUser!.uid,
        'isLivenessVerified',
        true,
      );

      final extraData = GoRouterState.of(context).extra;
      final bool returnToProfile = (extraData is Map<String, dynamic>)
          ? (extraData['returnToProfile'] ?? false)
          : false;

      if (mounted) {
        if (returnToProfile) {
          context.pushReplacement(UserProfilePage.pageName);
        } else {
          context.go(VerificationSuccessPage.pageName);
        }
      }
    } catch (e) {
      print('Error handling video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload video: $e'),
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

  @override
  void dispose() {
    _faceProcTimer?.cancel();
    _controller?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<LivenessBloc, LivenessState>(
        listener: (context, state) async {
          if (state.recordingState == RecordingState.completed) {
            await _stopAndUploadRecording(context);
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // Background gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
              ),

              // Camera preview with face oval overlay
              if (_isCameraInitialized && _controller != null)
                OvalFaceCameraPreview(
                  controller: _controller!,
                  recordingState: state.recordingState,
                  // We'll provide our own instructions, not duplicated
                  instruction: '',
                ),

              // Loading indicator
              if (!_isCameraInitialized)
                const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),

              // UI Elements
              _buildUIOverlay(context, state),

              // Verification failed overlay
              if (_verificationFailed) _buildVerificationFailure(),

              // Processing overlay
              if (_isUploading) _buildProcessingOverlay(),

              // Action button
              if (!_isUploading && !_verificationFailed)
                _buildActionButton(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUIOverlay(BuildContext context, LivenessState state) {
    return SafeArea(
      child: Column(
        children: [
          _buildTopBar(context, state),
          if (state.isRecording) ...[
            _buildProgressIndicator(context, state),
            const Spacer(),
            _buildInstructionCard(state),
            const SizedBox(height: 100), // Space for button
          ],
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, LivenessState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
          const Spacer(),
          if (state.isRecording)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
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
                      fontWeight: FontWeight.w500,
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

  Widget _buildProgressIndicator(BuildContext context, LivenessState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: state.recordingDuration.inSeconds / 15,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.tertiary,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${state.recordingDuration.inSeconds}s / 15s',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildInstructionCard(LivenessState state) {
    String getPromptIcon() {
      if (state.recordingState == RecordingState.lookUp) return '↑';
      if (state.recordingState == RecordingState.lookDown) return '↓';
      if (state.recordingState == RecordingState.lookLeft) return '←';
      if (state.recordingState == RecordingState.lookRight) return '→';
      return '';
    }

    String getCompletedText() {
      int count = _completedMovementsCount;
      if (count == 0) return 'Complete 2 movements';
      if (count == 1) return '1 of 2 movements detected';
      return '$count movements detected';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main instruction
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (getPromptIcon().isNotEmpty)
                Text(
                  getPromptIcon(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(width: 12),
              Text(
                state.instruction,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Movement indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMovementIndicator('Up', _completedMovements['up']!),
              _buildMovementIndicator('Down', _completedMovements['down']!),
              _buildMovementIndicator('Left', _completedMovements['left']!),
              _buildMovementIndicator('Right', _completedMovements['right']!),
            ],
          ),

          const SizedBox(height: 12),

          // Progress text
          Text(
            getCompletedText(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: _completedMovementsCount >= 2
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildMovementIndicator(String label, bool completed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: completed
                  ? Colors.green.withOpacity(0.3)
                  : Colors.white.withOpacity(0.1),
              border: Border.all(
                color: completed ? Colors.green : Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: Icon(
                completed ? Icons.check : Icons.arrow_drop_up,
                color: completed ? Colors.green : Colors.white.withOpacity(0.5),
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: completed ? Colors.green : Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontWeight: completed ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationFailure() {
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
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
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Verification Failed',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Please complete at least 2 different head movements during the verification process.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _startRecording,
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: Lottie.network(
                'https://lottie.host/c9ef1b27-5c36-4287-98d0-f6cde70ae043/KKBXQbo4ma.json',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const CircularProgressIndicator(
                    color: Colors.white,
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Processing Video',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'Analyzing facial movements...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ).animate().fadeIn().scale(),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, LivenessState state) {
    if (state.recordingState == RecordingState.initial) {
      return Positioned(
        bottom: 30,
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
                vertical: 16,
              ),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ).animate().fadeIn().scale(),
        ),
      );
    }

    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: 70,
          height: 70,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.videocam,
              color: Theme.of(context).colorScheme.primary,
              size: 36,
            ),
          ),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .scale(
              duration: const Duration(seconds: 1),
              begin: const Offset(1, 1),
              end: const Offset(1.15, 1.15),
            )
            .then()
            .scale(
              duration: const Duration(seconds: 1),
              begin: const Offset(1.15, 1.15),
              end: const Offset(1, 1),
            ),
      ),
    );
  }
}
