import '../../../../../core/bloc/base_bloc_state.dart';

class OnboardingPageState extends BaseBlocState {
  final int currentPage;

  const OnboardingPageState({this.currentPage = 0});

  OnboardingPageState copyWith({int? currentPage}) {
    return OnboardingPageState(
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [currentPage];
}

