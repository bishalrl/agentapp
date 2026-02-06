import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Enhanced metric card with large number, label, trend indicator, and optional chart.
/// Color-coded by status (success/warning/error).
class MetricCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;
  final Color? color;
  final double? trendValue; // Positive = up, Negative = down, null = no trend
  final String? trendLabel;
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.color,
    this.trendValue,
    this.trendLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.colorScheme.primary;
    final isPositive = trendValue != null && trendValue! > 0;
    final isNegative = trendValue != null && trendValue! < 0;

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingS),
            decoration: BoxDecoration(
              color: cardColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
            ),
            child: Icon(
              icon,
              color: cardColor,
              size: 24,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
        ],
        Text(
          value,
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
            fontSize: 32,
          ),
        ),
        const SizedBox(height: AppTheme.spacingXS),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        if (trendValue != null) ...[
          const SizedBox(height: AppTheme.spacingS),
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                size: 16,
                color: isPositive ? AppTheme.successColor : AppTheme.errorColor,
              ),
              const SizedBox(width: 4),
              Text(
                trendLabel ?? '${isPositive ? '+' : ''}${trendValue!.toStringAsFixed(1)}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isPositive ? AppTheme.successColor : AppTheme.errorColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ],
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              border: Border.all(
                color: AppTheme.lightBorderColor,
                width: 1,
              ),
            ),
            child: content,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: AppTheme.lightBorderColor,
          width: 1,
        ),
      ),
      child: content,
    );
  }
}
