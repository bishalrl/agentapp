import '../../../../../core/bloc/base_bloc_state.dart';

class OnboardingState extends BaseBlocState {
  final bool isCompleted;
  final int currentStep;
  final bool isLoading;
  final String? errorMessage;

  const OnboardingState({
    this.isCompleted = false,
    this.currentStep = 0,
    this.isLoading = false,
    this.errorMessage,
  });

  OnboardingState copyWith({
    bool? isCompleted,
    int? currentStep,
    bool? isLoading,
    String? errorMessage,
  }) {
    return OnboardingState(
      isCompleted: isCompleted ?? this.isCompleted,
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isCompleted, currentStep, isLoading, errorMessage];
}

