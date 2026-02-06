import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

/// Breadcrumb navigation item.
class BreadcrumbItem {
  final String label;
  final String? route;

  const BreadcrumbItem({
    required this.label,
    this.route,
  });
}

/// Breadcrumb navigation showing navigation path with clickable parent levels.
class BreadcrumbNav extends StatelessWidget {
  final List<BreadcrumbItem> items;

  const BreadcrumbNav({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (items.isEmpty || items.length == 1) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      child: Row(
        children: [
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == items.length - 1;

            return Row(
              children: [
                if (item.route != null && !isLast)
                  InkWell(
                    onTap: () => context.go(item.route!),
                    child: Text(
                      item.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                else
                  Text(
                    item.label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isLast
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                      fontWeight: isLast ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                if (!isLast) ...[
                  const SizedBox(width: AppTheme.spacingXS),
                  Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: AppTheme.textTertiary,
                  ),
                  const SizedBox(width: AppTheme.spacingXS),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }
}
