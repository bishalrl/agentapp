import '../../../../core/utils/result.dart';
import '../entities/onboarding_entity.dart';

abstract class OnboardingRepository {
  Future<Result<OnboardingEntity>> getOnboardingStatus();
  Future<Result<void>> completeOnboarding();
  Future<Result<void>> setOnboardingStep(int step);
}

