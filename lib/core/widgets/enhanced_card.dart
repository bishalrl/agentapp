import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Card elevation variants.
enum CardElevation {
  flat, // No shadow, border only
  raised, // Subtle shadow
  elevated, // Prominent shadow
}

class EnhancedCard extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final CardElevation elevation;
  final Widget? footer; // Optional footer actions
  final bool showSkeleton; // Loading skeleton variant

  const EnhancedCard({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.onTap,
    this.borderRadius,
    this.boxShadow,
    this.footer,
    this.elevation = CardElevation.raised,
    this.showSkeleton = false,
    this.border,
  }) : assert(child != null || showSkeleton, 'Either child or showSkeleton must be provided');

  List<BoxShadow> _getDefaultShadow() {
    switch (elevation) {
      case CardElevation.flat:
        return [];
      case CardElevation.raised:
        return [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ];
      case CardElevation.elevated:
        return [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (showSkeleton) {
      return Container(
        padding: padding ?? const EdgeInsets.all(AppTheme.spacingM),
        margin: margin,
        decoration: BoxDecoration(
          color: backgroundColor ?? theme.cardColor,
          borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusM),
          border: border ?? Border.all(
            color: AppTheme.lightBorderColor,
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 16,
              width: 100,
              decoration: BoxDecoration(
                color: AppTheme.lightBorderColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Container(
              height: 24,
              width: 150,
              decoration: BoxDecoration(
                color: AppTheme.lightBorderColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      );
    }
    
    Widget cardContent = Container(
      padding: padding ?? const EdgeInsets.all(AppTheme.spacingM),
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.cardColor,
        borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusM),
        border: border ?? (elevation == CardElevation.flat
            ? Border.all(
                color: AppTheme.lightBorderColor,
                width: 1,
              )
            : null),
        boxShadow: boxShadow ?? _getDefaultShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (child != null) child!,
          if (footer != null) ...[
            const SizedBox(height: AppTheme.spacingM),
            const Divider(
              color: AppTheme.lightBorderColor,
              height: 1,
            ),
            const SizedBox(height: AppTheme.spacingS),
            footer!,
          ],
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusM),
          splashColor: AppTheme.primaryColor.withOpacity(0.1),
          highlightColor: AppTheme.primaryColor.withOpacity(0.05),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
