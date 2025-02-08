import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:smartkyc/core/theme/app_color_scheme.dart';
import 'package:smartkyc/config/routes.dart';
import 'package:smartkyc/features/language/presentation/widgets/language_switcher.dart';
import 'package:smartkyc/l10n/app_localizations.dart';

class VerificationStepsPage extends StatelessWidget {
  const VerificationStepsPage({super.key});

  static const pageName = "/verificationStep";

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColorScheme.getGradientColors(isDark),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 50,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.verificationSteps,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color:
                                isDark ? AppColorScheme.darkText : Colors.white,
                          ),
                        ).animate().fadeIn().slideX(),
                        const SizedBox(height: 8),
                        Text(
                          l10n.verificationStepsDesc,
                          style: TextStyle(
                            fontSize: 16,
                            color: (isDark
                                    ? AppColorScheme.darkText
                                    : Colors.white)
                                .withOpacity(0.8),
                          ),
                        ).animate().fadeIn().slideX(),
                        const SizedBox(height: 48),
                        _buildVerificationSteps(context, isDark),
                        const SizedBox(height: 32),
                        FilledButton(
                          onPressed: () async => context.go(
                            await handleKYCNavigation(context),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                isDark ? AppColorScheme.darkText : Colors.white,
                            foregroundColor:
                                Theme.of(context).colorScheme.primary,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            l10n.startVerification,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ).animate().fadeIn().scale(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationSteps(BuildContext context, bool isDark) {
    final steps = [
      {
        'icon': Icons.email_outlined,
        'title': AppLocalizations.of(context).emailVerification,
        'subtitle': AppLocalizations.of(context).emailVerificationDesc,
      },
      {
        'icon': Icons.document_scanner_outlined,
        'title': AppLocalizations.of(context).documentUpload,
        'subtitle': AppLocalizations.of(context).documentUploadDesc,
      },
      {
        'icon': Icons.face_outlined,
        'title': AppLocalizations.of(context).selfieCapture,
        'subtitle': AppLocalizations.of(context).selfieCaptureDesc,
      },
      {
        'icon': Icons.verified_user_outlined,
        'title': AppLocalizations.of(context).livenessCheck,
        'subtitle': AppLocalizations.of(context).livenessCheckDesc,
      },
      {
        'icon': Icons.check_circle_outline,
        'title': AppLocalizations.of(context).verificationComplete,
        'subtitle': AppLocalizations.of(context).verificationCompleteDesc,
      },
    ];

    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isLast = index == steps.length - 1;

        return Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: (isDark ? AppColorScheme.darkText : Colors.white)
                        .withOpacity(0.38),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    step["icon"] as IconData,
                    color: isDark ? AppColorScheme.darkText : Colors.white,
                    size: 24,
                  ),
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
                          color:
                              isDark ? AppColorScheme.darkText : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step['subtitle'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              (isDark ? AppColorScheme.darkText : Colors.white)
                                  .withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ).animate().fadeIn().slideX(),
            if (!isLast)
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Container(
                  width: 2,
                  height: 40,
                  color: (isDark ? AppColorScheme.darkText : Colors.white)
                      .withOpacity(0.2),
                ).animate().fadeIn().scale(),
              ),
          ],
        );
      }).toList(),
    );
  }
}
