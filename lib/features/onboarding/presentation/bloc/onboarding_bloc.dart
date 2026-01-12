import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart';
import '../../domain/usecases/get_onboarding_status.dart';
import '../../domain/usecases/complete_onboarding.dart';
import '../../domain/entities/onboarding_entity.dart';
import 'events/onboarding_event.dart';
import 'states/onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final GetOnboardingStatus getOnboardingStatus;
  final CompleteOnboarding completeOnboarding;

  OnboardingBloc({
    required this.getOnboardingStatus,
    required this.completeOnboarding,
  }) : super(const OnboardingState()) {
    on<GetOnboardingStatusEvent>(_onGetOnboardingStatus);
    on<CompleteOnboardingEvent>(_onCompleteOnboarding);
  }

  Future<void> _onGetOnboardingStatus(
    GetOnboardingStatusEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    print('🔵 OnboardingBloc._onGetOnboardingStatus called');
    emit(state.copyWith(isLoading: true, errorMessage: null));
    print('   State emitted: isLoading=true');
    
    final result = await getOnboardingStatus();
    
    if (result is Error<OnboardingEntity>) {
      print('   ❌ GetOnboardingStatus Error: ${result.failure.message}');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: result.failure.message,
      ));
    } else if (result is Success<OnboardingEntity>) {
      final onboarding = result.data;
      print('   ✅ GetOnboardingStatus Success: isCompleted=${onboarding.isCompleted}, step=${onboarding.currentStep}');
      emit(
        state.copyWith(
          isCompleted: onboarding.isCompleted,
          currentStep: onboarding.currentStep,
          isLoading: false,
          errorMessage: null,
        ),
      );
      print('   State emitted: isCompleted=${onboarding.isCompleted}, currentStep=${onboarding.currentStep}');
    }
  }

  Future<void> _onCompleteOnboarding(
    CompleteOnboardingEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    print('🔵 OnboardingBloc._onCompleteOnboarding called');
    emit(state.copyWith(isLoading: true, errorMessage: null));
    print('   State emitted: isLoading=true');
    
    final result = await completeOnboarding();
    
    if (result is Error) {
      print('   ❌ CompleteOnboarding Error: ${result.failure.message}');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: result.failure.message,
      ));
    } else if (result is Success) {
      print('   ✅ CompleteOnboarding Success');
      emit(
        state.copyWith(
          isCompleted: true,
          currentStep: 0,
          isLoading: false,
          errorMessage: null,
        ),
      );
      print('   State emitted: isCompleted=true');
    }
  }
}
