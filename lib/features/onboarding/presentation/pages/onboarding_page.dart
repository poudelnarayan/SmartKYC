import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';
import '../widgets/onboarding_content.dart';

class OnboardingPage extends StatelessWidget {
  OnboardingPage({Key? key}) : super(key: key);

  final PageController _pageController = PageController();

  final List<Map<String, String>> onboardingData = [
    {
      'image': 'assets/images/onboarding1.png',
      'title': 'Secure Document Upload',
      'description':
          'Upload or capture your documents with bank-grade security. Your data is encrypted and protected at all times.',
    },
    {
      'image': 'assets/images/onboarding2.png',
      'title': 'AI-Powered Verification',
      'description':
          'Experience instant identity verification powered by advanced AI technology. Quick, accurate, and hassle-free.',
    },
    {
      'image': 'assets/images/onboarding3.png',
      'title': 'Fast & Reliable Process',
      'description':
          'Complete your KYC verification securely in minutes. Our streamlined process ensures a smooth experience.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingBloc(),
      child: BlocConsumer<OnboardingBloc, OnboardingState>(
        listener: (context, state) {
          if (state is OnboardingCompleted) {
            context.go('/upload-document');
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: () {
                        context
                            .read<OnboardingBloc>()
                            .add(SkipOnboardingEvent());
                      },
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
                              'Back',
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
                            state.isLastPage ? 'Get Started' : 'Next',
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
