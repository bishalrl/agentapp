import '../../../../core/utils/result.dart';
import '../entities/onboarding_entity.dart';
import '../repositories/onboarding_repository.dart';

class GetOnboardingStatus {
  final OnboardingRepository repository;
  
  GetOnboardingStatus(this.repository);
  
  Future<Result<OnboardingEntity>> call() async {
    return await repository.getOnboardingStatus();
  }
}

