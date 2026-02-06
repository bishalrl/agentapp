import 'package:agentapp/core/widgets/enhanced_card.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final double? trendValue; // Positive = up, Negative = down, null = no trend
  final String? trendLabel;
  final String? comparisonValue; // Comparison value (e.g., "vs last week")
  final Color? cardColor; // Color variant for the card

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
    this.trendValue,
    this.trendLabel,
    this.comparisonValue,
    this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconBgColor = backgroundColor ?? 
        iconColor?.withOpacity(0.08) ?? 
        (cardColor ?? AppTheme.primaryColor).withOpacity(0.08);
    final iconColorValue = iconColor ?? cardColor ?? AppTheme.primaryColor;
    final isPositive = trendValue != null && trendValue! > 0;
    final isNegative = trendValue != null && trendValue! < 0;

    return EnhancedCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppTheme.spacingM),
      backgroundColor: cardColor?.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Icon(
                  icon,
                  color: iconColorValue,
                  size: 24,
                ),
              ),
              if (trendValue != null)
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
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXS),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          if (comparisonValue != null) ...[
            const SizedBox(height: AppTheme.spacingXS),
            Text(
              comparisonValue!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textTertiary,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
