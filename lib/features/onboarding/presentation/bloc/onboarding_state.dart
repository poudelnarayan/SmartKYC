abstract class OnboardingState {
  final int pageIndex;

  OnboardingState(this.pageIndex);
}

class OnboardingInitial extends OnboardingState {
  OnboardingInitial() : super(0);
}

class OnboardingPageChanged extends OnboardingState {
  OnboardingPageChanged(int index) : super(index);
}
