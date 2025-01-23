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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LivenessBloc(),
      child: Scaffold(
        body: BlocConsumer<LivenessBloc, LivenessState>(
          listener: (context, state) {
            if (state.recordingState == RecordingState.completed) {
              context.go('/success');
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF2563EB).withOpacity(0.7),
                        Colors.transparent,
                        Colors.transparent,
                        Color(0xFF3B82F6).withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                // Camera Preview with Gradient Overlay
                if (_isCameraInitialized && _controller != null)
                  Center(
                    child: OvalFaceCameraPreview(controller: _controller!),
                  )
                else
                  const Center(
                    child: CircularProgressIndicator(),
                  ),

                // UI Overlay
                SafeArea(
                  child: Column(
                    children: [
                      _buildHeader(context, state),
                      const Spacer(),
                      _buildProgressIndicator(context, state),
                      const SizedBox(height: 32),
                      if (state.recordingState == RecordingState.initial)
                        _buildStartButton(context)
                      else
                        _buildRecordingIndicator(context, state),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, LivenessState state) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getInstructionIcon(state.recordingState),
            size: 32,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            state.instruction,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY();
  }

  Widget _buildProgressIndicator(BuildContext context, LivenessState state) {
    if (!state.isRecording) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: state.recordingDuration.inSeconds / 15,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${state.recordingDuration.inSeconds} / 15 seconds',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildStartButton(BuildContext context) {
    return FilledButton.icon(
      onPressed: () =>
          context.read<LivenessBloc>().add(StartDetectionProcess()),
      icon: const Icon(Icons.play_arrow),
      label: const Text('Start Verification'),
      style: FilledButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 16,
        ),
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildRecordingIndicator(BuildContext context, LivenessState state) {
    return Container(
      width: 80,
      height: 80,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.videocam,
          color: Colors.white,
          size: 32,
        ),
      ),
    ).animate(onPlay: (controller) => controller.repeat()).scale(
          duration: const Duration(seconds: 1),
          begin: const Offset(1, 1),
          end: const Offset(1.2, 1.2),
        );
  }

  IconData _getInstructionIcon(RecordingState state) {
    switch (state) {
      case RecordingState.lookUp:
        return Icons.arrow_upward;
      case RecordingState.lookDown:
        return Icons.arrow_downward;
      case RecordingState.lookLeft:
        return Icons.arrow_back;
      case RecordingState.lookRight:
        return Icons.arrow_forward;
      case RecordingState.recording:
        return Icons.videocam;
      case RecordingState.completed:
        return Icons.check_circle;
      default:
        return Icons.face;
    }
  }
}
