import '../../../../../core/bloc/base_bloc_event.dart';

abstract class OnboardingPageEvent extends BaseBlocEvent {
  const OnboardingPageEvent();
}

class OnboardingPageChangedEvent extends OnboardingPageEvent {
  final int page;

  const OnboardingPageChangedEvent(this.page);

  @override
  List<Object?> get props => [page];
}

