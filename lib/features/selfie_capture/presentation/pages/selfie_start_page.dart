import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:smartkyc/l10n/app_localizations.dart';
import 'package:smartkyc/features/selfie_capture/presentation/pages/selfie_capture_page.dart';

import '../../../../config/routes.dart';
import '../../../../core/presentation/widgets/skip_button.dart';

class SelfieStartPage extends StatefulWidget {
  const SelfieStartPage({super.key});

  static const pageName = "/selfieStart";

  @override
  State<SelfieStartPage> createState() => _SelfieStartPageState();
}

class _SelfieStartPageState extends State<SelfieStartPage> {
  String nextRoute = '';

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Background color
      statusBarIconBrightness: Brightness.dark,
    ));
    _checkNavigation();
    super.initState();
  }

  Future<void> _checkNavigation() async {
    final route = await handleKYCNavigation(context, skipStep: 'selfie');
    if (mounted) {
      setState(() {
        nextRoute = route;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Background color
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));
    final l10n = AppLocalizations.of(context);
    final extraData = GoRouterState.of(context).extra;
    final bool returnToProfile = (extraData is Map<String, dynamic>)
        ? (extraData['returnToProfile'] ?? false)
        : false;

    return SafeArea(
      child: Scaffold(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            if (!returnToProfile)
              Column(
                children: [
                  const SizedBox(
                    height: 14,
                  ),
                  SkipButton(
                    onSkip: () {
                      context.go(nextRoute);
                    },
                    backgroundColor:
                        isDark ? Colors.white.withOpacity(0.1) : null,
                    textColor: isDark ? Colors.white : null,
                  ),
                ],
              ),
            const SizedBox(width: 25),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 24.0,
                right: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.selfieCapture,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.selfieCaptureDesc,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.camera_front,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.selfieGuidelines,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[850] : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildGuidelineItem(
                          context,
                          icon: Icons.wb_sunny,
                          title: l10n.goodLighting,
                          description: l10n.goodLightingDesc,
                        ),
                        const SizedBox(height: 20),
                        _buildGuidelineItem(
                          context,
                          icon: Icons.face,
                          title: l10n.facePosition,
                          description: l10n.facePositionDesc,
                        ),
                        const SizedBox(height: 20),
                        _buildGuidelineItem(
                          context,
                          icon: Icons.no_flash,
                          title: l10n.noFlash,
                          description: l10n.noFlashDesc,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.pushNamed(
                      SelfieCapturePage.pageName,
                      extra: extraData,
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    icon: const Icon(Icons.camera_alt),
                    label: Text(
                      l10n.startCamera,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.lightingTip,
                            style: TextStyle(
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 14,
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
        ),
      ),
    );
  }

  Widget _buildGuidelineItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 24,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : null,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
