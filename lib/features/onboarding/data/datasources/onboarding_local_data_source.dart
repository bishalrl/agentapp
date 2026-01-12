import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/onboarding_model.dart';

abstract class OnboardingLocalDataSource {
  Future<OnboardingModel> getOnboardingStatus();
  Future<void> completeOnboarding();
  Future<void> setOnboardingStep(int step);
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  final SharedPreferences sharedPreferences;
  
  OnboardingLocalDataSourceImpl(this.sharedPreferences);
  
  @override
  Future<OnboardingModel> getOnboardingStatus() async {
    try {
      final isCompleted = sharedPreferences.getBool(AppConstants.onboardingKey) ?? false;
      final currentStep = sharedPreferences.getInt('onboarding_step') ?? 0;
      
      return OnboardingModel(
        isCompleted: isCompleted,
        currentStep: currentStep,
      );
    } catch (e) {
      throw CacheException('Failed to get onboarding status: ${e.toString()}');
    }
  }
  
  @override
  Future<void> completeOnboarding() async {
    try {
      await sharedPreferences.setBool(AppConstants.onboardingKey, true);
      await sharedPreferences.setInt('onboarding_step', 0);
    } catch (e) {
      throw CacheException('Failed to complete onboarding: ${e.toString()}');
    }
  }
  
  @override
  Future<void> setOnboardingStep(int step) async {
    try {
      await sharedPreferences.setInt('onboarding_step', step);
    } catch (e) {
      throw CacheException('Failed to set onboarding step: ${e.toString()}');
    }
  }
}

