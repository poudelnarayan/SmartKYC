abstract class OnboardingEvent {}

class NextPageEvent extends OnboardingEvent {}

class PreviousPageEvent extends OnboardingEvent {}

class SkipOnboardingEvent extends OnboardingEvent {}

class CompleteOnboardingEvent extends OnboardingEvent {}
