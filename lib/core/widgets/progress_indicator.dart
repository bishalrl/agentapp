import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Step-by-step progress indicator for multi-step flows.
/// Shows visual connection between steps with current/completed/pending states.
class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String>? stepLabels;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.stepLabels,
  }) : assert(currentStep >= 0 && currentStep <= totalSteps);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          children: List.generate(totalSteps, (index) {
            final stepNumber = index + 1;
            final isCompleted = stepNumber < currentStep;
            final isCurrent = stepNumber == currentStep;
            final isPending = stepNumber > currentStep;

            final primary = theme.colorScheme.primary;
            final inactive = theme.dividerColor;

            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isCompleted || isCurrent ? primary : inactive,
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCompleted || isCurrent ? primary : inactive,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isCompleted
                          ? Icon(
                              Icons.check,
                              color: theme.colorScheme.onPrimary,
                              size: 18,
                            )
                          : Text(
                              stepNumber.toString(),
                              style: TextStyle(
                                color: isCurrent
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurface.withOpacity(0.6),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                    ),
                  ),
                  if (index < totalSteps - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: isCompleted ? primary : inactive,
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        if (stepLabels != null && stepLabels!.length == totalSteps) ...[
          const SizedBox(height: AppTheme.spacingS),
          Row(
            children: stepLabels!.asMap().entries.map((entry) {
              final index = entry.key;
              final label = entry.value;
              final stepNumber = index + 1;
              final isCurrent = stepNumber == currentStep;
              final isCompleted = stepNumber < currentStep;

              return Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isCurrent || isCompleted
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
