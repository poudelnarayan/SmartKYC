import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class VerificationProgressOverlay extends StatefulWidget {
  final int completedStep;
  final String nextRoute;

  const VerificationProgressOverlay({
    super.key,
    required this.completedStep,
    required this.nextRoute,
  });

  @override
  State<VerificationProgressOverlay> createState() =>
      _VerificationProgressOverlayState();
}

class _VerificationProgressOverlayState
    extends State<VerificationProgressOverlay> with TickerProviderStateMixin {
  late AnimationController _checkmarkController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize checkmark animation controller
    _checkmarkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Initialize pulse animation controller
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Create pulse animation
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Start pulse animation with repeat
    _pulseController.repeat(reverse: true);

    // Auto-dismiss after 3 seconds and navigate
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        context.go(widget.nextRoute);
      }
    });
  }

  @override
  void dispose() {
    _checkmarkController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: Colors.black.withOpacity(0.9),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => context.go(widget.nextRoute),
                    icon: const Icon(Icons.skip_next, color: Colors.white),
                    label: Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      _buildSteps(context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSteps(BuildContext context) {
    final steps = [
      {
        'icon': Icons.email_outlined,
        'title': AppLocalizations.of(context)!.emailVerification,
        'subtitle': AppLocalizations.of(context)!.emailVerificationDesc,
      },
      {
        'icon': Icons.document_scanner_outlined,
        'title': AppLocalizations.of(context)!.documentUpload,
        'subtitle': AppLocalizations.of(context)!.documentUploadDesc,
      },
      {
        'icon': Icons.face_outlined,
        'title': AppLocalizations.of(context)!.selfieCapture,
        'subtitle': AppLocalizations.of(context)!.selfieCaptureDesc,
      },
      {
        'icon': Icons.verified_user_outlined,
        'title': AppLocalizations.of(context)!.livenessCheck,
        'subtitle': AppLocalizations.of(context)!.livenessCheckDesc,
      },
      {
        'icon': Icons.check_circle_outline,
        'title': AppLocalizations.of(context)!.verificationComplete,
        'subtitle': AppLocalizations.of(context)!.verificationCompleteDesc,
      },
    ];

    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isLast = index == steps.length - 1;
        final isCompleted = index <= widget.completedStep;
        final isCurrent = index == widget.completedStep;

        return Column(
          children: [
            Row(
              children: [
                _buildStepIndicator(
                  context,
                  icon: step['icon'] as IconData,
                  isCompleted: isCompleted,
                  isCurrent: isCurrent,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step['title'] as String,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isCompleted
                              ? Colors.green
                              : Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step['subtitle'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
                .animate(
                  delay: Duration(milliseconds: index * 200),
                )
                .fadeIn()
                .slideX(),
            if (!isLast)
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Container(
                  width: 2,
                  height: 40,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildStepIndicator(
    BuildContext context, {
    required IconData icon,
    required bool isCompleted,
    required bool isCurrent,
  }) {
    return Stack(
      children: [
        // Base circle
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: isCompleted ? _pulseAnimation.value : 1.0,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green
                      : isCurrent
                          ? Colors.white
                          : Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                  boxShadow: isCompleted
                      ? [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 4,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  isCompleted ? Icons.check : icon,
                  color: isCompleted
                      ? Colors.white
                      : isCurrent
                          ? Theme.of(context).colorScheme.primary
                          : Colors.white.withOpacity(0.5),
                  size: 24,
                ),
              ),
            );
          },
        ),

        // Premium checkmark animation
        if (isCompleted)
          Positioned(
            left: -36,
            top: -36,
            child: SizedBox(
              width: 120,
              height: 120,
              child: Lottie.network(
                // Using a more premium and smoother checkmark animation
                'https://assets10.lottiefiles.com/packages/lf20_jbrw3hcz.json',
                repeat: false,
                controller: _checkmarkController,
                onLoaded: (composition) {
                  _checkmarkController
                    ..duration = composition.duration
                    ..forward();
                },
              ),
            ),
          ),

        // Success ripple effect
        if (isCompleted)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.green.withOpacity(0.5),
                  width: 2,
                ),
              ),
            )
                .animate(
                  onPlay: (controller) => controller.repeat(),
                )
                .scale(
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeOut,
                  begin: const Offset(1, 1),
                  end: const Offset(2, 2),
                )
                .fadeOut(
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeOut,
                ),
          ),
      ],
    );
  }
}
