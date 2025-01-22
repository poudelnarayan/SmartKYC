import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';
import '../widgets/onboarding_content.dart';

class OnboardingPage extends StatelessWidget {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingBloc(),
      child: Scaffold(
        body: BlocListener<OnboardingBloc, OnboardingState>(
          listener: (context, state) {
            _pageController.animateToPage(
              state.pageIndex,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    context.read<OnboardingBloc>().add(NextPageEvent());
                  },
                  children: [
                    OnboardingContent(
                      image: 'assets/images/onboarding1.png',
                      title: 'Secure Document Upload',
                      description: 'Upload or capture documents with security.',
                    ),
                    OnboardingContent(
                      image: 'assets/images/onboarding2.png',
                      title: 'AI-Powered Verification',
                      description: 'Instant identity verification via AI.',
                    ),
                    OnboardingContent(
                      image: 'assets/images/onboarding3.png',
                      title: 'Fast & Reliable Process',
                      description: 'Complete KYC verification securely.',
                    ),
                  ],
                ),
              ),
              BlocBuilder<OnboardingBloc, OnboardingState>(
                builder: (context, state) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (state.pageIndex > 0)
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<OnboardingBloc>()
                                .add(PreviousPageEvent());
                          },
                          child: Text('Back'),
                        ),
                      ElevatedButton(
                        onPressed: () {
                          if (state.pageIndex < 2) {
                            context.read<OnboardingBloc>().add(NextPageEvent());
                          } else {
                            context.go('/upload-document');
                          }
                        },
                        child:
                            Text(state.pageIndex == 2 ? 'Get Started' : 'Next'),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
