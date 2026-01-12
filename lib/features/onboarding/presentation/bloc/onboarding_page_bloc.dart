import 'package:flutter_bloc/flutter_bloc.dart';
import 'events/onboarding_page_event.dart';
import 'states/onboarding_page_state.dart';

class OnboardingPageBloc extends Bloc<OnboardingPageEvent, OnboardingPageState> {
  OnboardingPageBloc() : super(const OnboardingPageState()) {
    on<OnboardingPageChangedEvent>(_onPageChanged);
  }

  void _onPageChanged(
    OnboardingPageChangedEvent event,
    Emitter<OnboardingPageState> emit,
  ) {
    emit(state.copyWith(currentPage: event.page));
  }
}
