import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:smartkyc/l10n/app_localizations.dart';
import 'package:smartkyc/core/presentation/widgets/skip_button.dart';
import 'package:smartkyc/features/liveliness_detection/presentation/pages/liveness_detection_page.dart';
import 'package:smartkyc/features/user_profile/presentation/pages/user_profile_page.dart';

class LivenessDetectionStartPage extends StatelessWidget {
  const LivenessDetectionStartPage({super.key});

  static const pageName = "/livelinessDetectionStart";

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Background color
      statusBarIconBrightness: Brightness.light,
    ));
    final l10n = AppLocalizations.of(context);
    final extraData = GoRouterState.of(context).extra;
    final bool returnToProfile = (extraData is Map<String, dynamic>)
        ? (extraData['returnToProfile'] ?? false)
        : false;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Colors.grey[900]!,
                    Colors.grey[850]!,
                  ]
                : [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 21, right: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        if (!returnToProfile)
                          SkipButton(
                            onSkip: () {
                              context.go(UserProfilePage.pageName);
                            },
                            textColor: Colors.white,
                            backgroundColor:
                                isDark ? Colors.white.withOpacity(0.1) : null,
                          ),
                        if (returnToProfile)
                          IconButton(
                            onPressed: context.pop,
                            icon: const Icon(
                              Icons.cancel,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.security,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Center(
                          child: Text(
                            l10n.faceVerification,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.faceVerificationDesc,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark
                                ? Colors.grey[300]
                                : Colors.white.withOpacity(0.8),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),
                        _buildRequirementsList(context, isDark),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.white.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.verificationTimeEstimate,
                      style: TextStyle(
                        color: isDark
                            ? Colors.grey[300]
                            : Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.pushNamed(
                          LivenessDetectionPage.pageName,
                          extra: extraData,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor:
                              isDark ? Colors.grey[900] : Colors.blue.shade900,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          l10n.beginVerification,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequirementsList(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);

    final requirements = [
      {
        'icon': Icons.wb_sunny_outlined,
        'title': l10n.goodLighting,
        'description': l10n.goodLightingDesc,
      },
      {
        'icon': Icons.face_outlined,
        'title': l10n.clearView,
        'description': l10n.clearViewDesc,
      },
      {
        'icon': Icons.camera_front_outlined,
        'title': l10n.cameraReady,
        'description': l10n.cameraReadyDesc,
      },
    ];

    return Column(
      children: requirements.map((requirement) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  requirement['icon'] as IconData,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      requirement['title'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      requirement['description'] as String,
                      style: TextStyle(
                        color: isDark
                            ? Colors.grey[300]
                            : Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
