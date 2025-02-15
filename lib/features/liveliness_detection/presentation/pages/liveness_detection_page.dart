import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
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
  static const pageName = "livelinessDetection";

  @override
  State<LivenessDetectionPage> createState() => _LivelinessPageState();
}

class _LivelinessPageState extends State<LivenessDetectionPage> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isUploading = false;
  // ignore: unused_field
  XFile? _recordedVideo;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
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

    try {
      await _controller!.startVideoRecording();
      context.read<LivenessBloc>().add(StartDetectionProcess());
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

  Future<void> _stopAndUploadRecording(BuildContext context) async {
    if (_controller == null || !_controller!.value.isInitialized) return;

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
    _controller?.dispose();

    context.read<LivenessBloc>().close();
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

              // Camera preview with face overlay
              if (_isCameraInitialized && _controller != null)
                OvalFaceCameraPreview(
                  controller: _controller!,
                  recordingState: state.recordingState,
                  instruction: state.instruction,
                ),

              // Loading indicator
              if (!_isCameraInitialized)
                const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),

              // UI Overlay
              SafeArea(
                child: Column(
                  children: [
                    _buildTopBar(context, state),
                    _buildProgressIndicator(context, state),
                  ],
                ),
              ),

              // Action button or uploading indicator
              if (_isUploading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.9),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 200,
                            height: 200,
                            child: Lottie.network(
                              // AI/ML processing animation
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
                              'Analyzing facial movements and gestures...',
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
                  ),
                )
              else
                _buildActionButton(context, state),
            ],
          );
        },
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
    if (!state.isRecording) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: state.recordingDuration.inSeconds / 15,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildActionButton(BuildContext context, LivenessState state) {
    if (state.recordingState == RecordingState.initial) {
      return Positioned(
        bottom: 30,
        left: MediaQuery.of(context).size.width / 4.5,
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
          ),
        ).animate().fadeIn().scale(),
      );
    }

    return Positioned(
      bottom: 30,
      left: MediaQuery.of(context).size.width / 2.5,
      child: Container(
        width: 60,
        height: 60,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white24,
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
            size: 32,
          ),
        ),
      )
          .animate(onPlay: (controller) => controller.repeat())
          .scale(
            duration: const Duration(seconds: 1),
            begin: const Offset(1, 1),
            end: const Offset(1.2, 1.2),
          )
          .then()
          .scale(
            duration: const Duration(seconds: 1),
            begin: const Offset(1.2, 1.2),
            end: const Offset(1, 1),
          ),
    );
  }
}
