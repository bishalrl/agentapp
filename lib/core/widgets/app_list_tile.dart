import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Shared list row: leading icon (optional status color), title, subtitle, trailing, onTap.
/// Uses AppTheme and theme text styles.
class AppListTile extends StatelessWidget {
  final Widget? leading;
  final IconData? leadingIcon;
  final Color? leadingIconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const AppListTile({
    super.key,
    this.leading,
    this.leadingIcon,
    this.leadingIconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = leadingIconColor ?? AppTheme.primaryColor;
    Widget leadingWidget = leading ?? (leadingIcon != null
        ? CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.1),
            child: Icon(leadingIcon, color: iconColor, size: 24),
          )
        : const SizedBox.shrink());

    return ListTile(
      leading: leadingWidget,
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
