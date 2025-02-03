import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import 'package:smartkyc/config/routes.dart';
import 'package:smartkyc/features/auth/presentation/pages/singin_page.dart';
import 'package:smartkyc/features/language/presentation/widgets/language_switcher.dart';
import 'package:smartkyc/l10n/app_localizations.dart';

class VerificationStepsPage extends StatelessWidget {
  const VerificationStepsPage({super.key});

  static const pageName = "/verificationStep";

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(
                  top: 16,
                  left: 16,
                  right: 16,
                  bottom: 3,
                ),
                child: LanguageSwitcher(),
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: Text(
                    l10n.languageSwitchWarn,
                    style: TextStyle(
                      color: Colors.white60,
                    ),
                  )),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.verificationSteps,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ).animate().fadeIn().slideX(),
                        const SizedBox(height: 8),
                        Text(
                          l10n.verificationStepsDesc,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ).animate().fadeIn().slideX(),
                        const SizedBox(height: 48),
                        _buildVerificationSteps(context),
                        const SizedBox(height: 32),
                        FilledButton(
                          onPressed: () async => context.go(
                            await handleKYCNavigation(context),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
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

  Widget _buildVerificationSteps(BuildContext context) {
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

        return Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Colors.white38,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    step["icon"] as IconData,
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
                        step['title'] as String,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step['subtitle'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
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
                  color: Colors.white.withOpacity(0.2),
                ).animate().fadeIn().scale(),
              ),
          ],
        );
      }).toList(),
    );
  }
}
