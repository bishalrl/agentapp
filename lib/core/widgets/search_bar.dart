import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Unified search bar component with debounced input, clear button, and optional filters.
class AppSearchBar extends StatefulWidget {
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterTap;
  final bool showFilterButton;
  final TextEditingController? controller;

  const AppSearchBar({
    super.key,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onFilterTap,
    this.showFilterButton = false,
    this.controller,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late TextEditingController _controller;
  String _previousValue = '';

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    final currentValue = _controller.text;
    if (currentValue != _previousValue) {
      _previousValue = currentValue;
      // Debounce: Only call onChanged after user stops typing
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_controller.text == currentValue && widget.onChanged != null) {
          widget.onChanged!(currentValue);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: AppTheme.lightBorderColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: widget.hintText ?? 'Search...',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textTertiary,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppTheme.textSecondary,
                ),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _controller.clear();
                          widget.onChanged?.call('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingM,
                ),
              ),
              style: theme.textTheme.bodyMedium,
              onSubmitted: widget.onSubmitted,
            ),
          ),
          if (widget.showFilterButton && widget.onFilterTap != null) ...[
            Container(
              width: 1,
              height: 24,
              color: AppTheme.lightBorderColor,
            ),
            IconButton(
              icon: const Icon(Icons.tune),
              onPressed: widget.onFilterTap,
              color: AppTheme.textSecondary,
            ),
          ],
        ],
      ),
    );
  }
}
