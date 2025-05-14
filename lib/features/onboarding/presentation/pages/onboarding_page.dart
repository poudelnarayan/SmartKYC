import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartkyc/features/language/presentation/widgets/language_switcher.dart';
import 'package:smartkyc/features/verification_steps/presentation/pages/verification_steps_page.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';
import '../widgets/onboarding_content.dart';
import 'package:smartkyc/l10n/app_localizations.dart';

class OnboardingPage extends StatefulWidget {
  OnboardingPage({Key? key}) : super(key: key);

  static const pageName = "/onBoarding";

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  @override
  void initState() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    super.initState();
  }

  List<Map<String, String>> _getOnboardingData(AppLocalizations l10n) => [
        {
          'image': 'assets/images/onboarding1.png',
          'title': l10n.onboardingTitle1,
          'description': l10n.onboardingDesc1,
        },
        {
          'image': 'assets/images/onboarding2.png',
          'title': l10n.onboardingTitle2,
          'description': l10n.onboardingDesc2,
        },
        {
          'image': 'assets/images/onboarding3.png',
          'title': l10n.onboardingTitle3,
          'description': l10n.onboardingDesc3,
        },
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final onboardingData = _getOnboardingData(l10n);

    return BlocProvider(
      create: (context) => OnboardingBloc(),
      child: BlocConsumer<OnboardingBloc, OnboardingState>(
        listener: (context, state) async {
          if (state is OnboardingCompleted) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('hasSeenOnboarding', true);
            context.go(VerificationStepsPage.pageName);
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            LanguageSwitcher(),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            context
                                .read<OnboardingBloc>()
                                .add(SkipOnboardingEvent());
                          },
                          child: Text(
                            l10n.skip,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: onboardingData.length,
                      onPageChanged: (index) {
                        context.read<OnboardingBloc>().add(
                              index > state.pageIndex
                                  ? NextPageEvent()
                                  : PreviousPageEvent(),
                            );
                      },
                      itemBuilder: (context, index) {
                        return OnboardingContent(
                          image: onboardingData[index]['image']!,
                          title: onboardingData[index]['title']!,
                          description: onboardingData[index]['description']!,
                          progress: (index + 1) / onboardingData.length,
                        ).animate().fadeIn().slideY();
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (state.pageIndex > 0)
                          TextButton(
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Text(
                              l10n.back,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        else
                          const SizedBox(width: 80),
                        FilledButton(
                          onPressed: () {
                            if (!state.isLastPage) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              context
                                  .read<OnboardingBloc>()
                                  .add(CompleteOnboardingEvent());
                            }
                          },
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            state.isLastPage ? l10n.getStarted : l10n.next,
                          ),
                        ),
                      ],
                    ).animate().fadeIn().slideY(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
