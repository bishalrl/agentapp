import '../../../../core/utils/result.dart';
import '../repositories/onboarding_repository.dart';

class CompleteOnboarding {
  final OnboardingRepository repository;
  
  CompleteOnboarding(this.repository);
  
  Future<Result<void>> call() async {
    return await repository.completeOnboarding();
  }
}

