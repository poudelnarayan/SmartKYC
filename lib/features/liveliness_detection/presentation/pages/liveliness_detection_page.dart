import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import '../bloc/liveliness_bloc.dart';
import '../bloc/liveliness_state.dart';
import '../bloc/liveliness_event.dart';
import '../widgets/oval_face_camera_preview.dart';
import '../../domain/entities/recording_state.dart';

class LivelinessPage extends StatefulWidget {
  const LivelinessPage({super.key});

  @override
  State<LivelinessPage> createState() => _LivelinessPageState();
}

class _LivelinessPageState extends State<LivelinessPage> {
  CameraController? _controller;
  bool _isCameraInitialized = false;

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

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocConsumer<LivenessBloc, LivenessState>(
        listener: (context, state) async {
          if (state.recordingState == RecordingState.completed) {
            await Future.delayed(Duration(milliseconds: 800));
            context.go('/success');
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
                      theme.colorScheme.primary.withOpacity(0.9),
                      Colors.black87,
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
          onPressed: () =>
              context.read<LivenessBloc>().add(StartDetectionProcess()),
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
