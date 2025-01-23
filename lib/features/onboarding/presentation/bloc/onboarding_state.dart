abstract class OnboardingState {
  final int pageIndex;
  final bool isLastPage;

  OnboardingState({
    required this.pageIndex,
    required this.isLastPage,
  });
}

class OnboardingInitial extends OnboardingState {
  OnboardingInitial() : super(pageIndex: 0, isLastPage: false);
}

class OnboardingPageChanged extends OnboardingState {
  OnboardingPageChanged({
    required int pageIndex,
    required bool isLastPage,
  }) : super(pageIndex: pageIndex, isLastPage: isLastPage);
}

class OnboardingCompleted extends OnboardingState {
  OnboardingCompleted() : super(pageIndex: 2, isLastPage: true);
}
