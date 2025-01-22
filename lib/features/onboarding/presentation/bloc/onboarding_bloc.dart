import 'package:flutter_bloc/flutter_bloc.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(OnboardingInitial()) {
    on<NextPageEvent>((event, emit) {
      if (state.pageIndex < 2) {
        emit(OnboardingPageChanged(state.pageIndex + 1));
      }
    });

    on<PreviousPageEvent>((event, emit) {
      if (state.pageIndex > 0) {
        emit(OnboardingPageChanged(state.pageIndex - 1));
      }
    });

    on<FinishOnboardingEvent>((event, emit) {
      emit(OnboardingPageChanged(2));
    });
  }
}
