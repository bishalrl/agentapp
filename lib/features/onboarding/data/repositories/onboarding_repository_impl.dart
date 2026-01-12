import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/onboarding_entity.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_local_data_source.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDataSource localDataSource;
  
  OnboardingRepositoryImpl(this.localDataSource);
  
  @override
  Future<Result<OnboardingEntity>> getOnboardingStatus() async {
    try {
      final model = await localDataSource.getOnboardingStatus();
      return Success(model);
    } on CacheException catch (e) {
      return Error(CacheFailure(e.message));
    } catch (e) {
      return Error(CacheFailure('Unexpected error: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<void>> completeOnboarding() async {
    try {
      await localDataSource.completeOnboarding();
      return const Success(null);
    } on CacheException catch (e) {
      return Error(CacheFailure(e.message));
    } catch (e) {
      return Error(CacheFailure('Unexpected error: ${e.toString()}'));
    }
  }
  
  @override
  Future<Result<void>> setOnboardingStep(int step) async {
    try {
      await localDataSource.setOnboardingStep(step);
      return const Success(null);
    } on CacheException catch (e) {
      return Error(CacheFailure(e.message));
    } catch (e) {
      return Error(CacheFailure('Unexpected error: ${e.toString()}'));
    }
  }
}

