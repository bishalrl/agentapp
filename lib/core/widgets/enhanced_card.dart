import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EnhancedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Border? border;

  const EnhancedCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.onTap,
    this.borderRadius,
    this.boxShadow,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget cardContent = Container(
      padding: padding ?? const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.cardColor,
        borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusM),
        border: border ?? Border.all(
          color: Colors.grey.shade100,
          width: 0.5,
        ),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
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
