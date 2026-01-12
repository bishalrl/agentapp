import '../../domain/entities/onboarding_entity.dart';

class OnboardingModel extends OnboardingEntity {
  const OnboardingModel({
    required super.isCompleted,
    required super.currentStep,
  });
  
  factory OnboardingModel.fromJson(Map<String, dynamic> json) {
    return OnboardingModel(
      isCompleted: json['isCompleted'] as bool? ?? false,
      currentStep: json['currentStep'] as int? ?? 0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'isCompleted': isCompleted,
      'currentStep': currentStep,
    };
  }
  
  factory OnboardingModel.fromEntity(OnboardingEntity entity) {
    return OnboardingModel(
      isCompleted: entity.isCompleted,
      currentStep: entity.currentStep,
    );
  }
}

