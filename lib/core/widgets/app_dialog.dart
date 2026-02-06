import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Theme-consistent dialog: title, content, cancel + primary actions.
class AppDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final String? cancelLabel;
  final String? primaryLabel;
  final VoidCallback? onCancel;
  final VoidCallback? onPrimary;

  const AppDialog({
    super.key,
    required this.title,
    required this.content,
    this.cancelLabel,
    this.primaryLabel,
    this.onCancel,
    this.onPrimary,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    String cancelLabel = 'Cancel',
    String? primaryLabel,
    VoidCallback? onCancel,
    VoidCallback? onPrimary,
  }) {
    return showDialog<T>(
      context: context,
      builder: (ctx) => AppDialog(
        title: title,
        content: content,
        cancelLabel: cancelLabel,
        primaryLabel: primaryLabel,
        onCancel: onCancel != null ? () { onCancel(); Navigator.of(ctx).pop(); } : () => Navigator.of(ctx).pop(),
        onPrimary: onPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: content,
      contentPadding: const EdgeInsets.fromLTRB(
        AppTheme.spacingL,
        AppTheme.spacingM,
        AppTheme.spacingL,
        AppTheme.spacingM,
      ),
      actions: [
        if (cancelLabel != null)
          TextButton(
            onPressed: onCancel ?? () => Navigator.of(context).pop(),
            child: Text(cancelLabel!),
          ),
        if (primaryLabel != null)
          ElevatedButton(
            onPressed: onPrimary ?? () => Navigator.of(context).pop(),
            child: Text(primaryLabel!),
          ),
      ],
    );
  }
}
