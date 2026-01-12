import '../../../../../core/bloc/base_bloc_event.dart';

abstract class OnboardingEvent extends BaseBlocEvent {
  const OnboardingEvent();
}

class GetOnboardingStatusEvent extends OnboardingEvent {
  const GetOnboardingStatusEvent();
}

class CompleteOnboardingEvent extends OnboardingEvent {
  const CompleteOnboardingEvent();
}

class SetOnboardingStepEvent extends OnboardingEvent {
  final int step;
  
  const SetOnboardingStepEvent(this.step);
  
  @override
  List<Object?> get props => [step];
}

