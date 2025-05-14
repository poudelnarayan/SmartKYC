import 'package:flutter_bloc/flutter_bloc.dart';
import 'onboarding_state.dart';
import 'onboarding_event.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  static const int totalPages = 3;

  OnboardingBloc() : super(OnboardingInitial()) {
    on<NextPageEvent>((event, emit) {
      final nextIndex = state.pageIndex + 1;
      if (nextIndex < totalPages) {
        emit(OnboardingPageChanged(
          pageIndex: nextIndex,
          isLastPage: nextIndex == totalPages - 1,
        ));
      } else {
        emit(OnboardingCompleted());
      }
    });

    on<PreviousPageEvent>((event, emit) {
      final previousIndex = state.pageIndex - 1;
      if (previousIndex >= 0) {
        emit(OnboardingPageChanged(
          pageIndex: previousIndex,
          isLastPage: false,
        ));
      }
    });

    on<SkipOnboardingEvent>((event, emit) {
      emit(OnboardingCompleted());
    });

    on<CompleteOnboardingEvent>((event, emit) {
      emit(OnboardingCompleted());
    });

    
  }
}
