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

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconBgColor = backgroundColor ?? iconColor?.withOpacity(0.08) ?? AppTheme.primaryColor.withOpacity(0.08);
    final iconColorValue = iconColor ?? AppTheme.primaryColor;

    return EnhancedCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppTheme.spacingM),
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
        ],
      ),
    );
  }
}
