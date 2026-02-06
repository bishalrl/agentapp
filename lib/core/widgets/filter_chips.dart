import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Filter chip item model.
class FilterChipItem {
  final String label;
  final String value;
  final IconData? icon;

  const FilterChipItem({
    required this.label,
    required this.value,
    this.icon,
  });
}

/// Horizontal scrollable filter chips with multi-select support, active state styling, and clear all option.
class FilterChips extends StatelessWidget {
  final List<FilterChipItem> items;
  final List<String> selectedValues;
  final ValueChanged<List<String>> onSelectionChanged;
  final bool multiSelect;
  final bool showClearAll;

  const FilterChips({
    super.key,
    required this.items,
    required this.selectedValues,
    required this.onSelectionChanged,
    this.multiSelect = false,
    this.showClearAll = true,
  });

  void _toggleSelection(String value) {
    final newSelection = List<String>.from(selectedValues);
    if (multiSelect) {
      if (newSelection.contains(value)) {
        newSelection.remove(value);
      } else {
        newSelection.add(value);
      }
    } else {
      newSelection.clear();
      if (!selectedValues.contains(value)) {
        newSelection.add(value);
      }
    }
    onSelectionChanged(newSelection);
  }

  void _clearAll() {
    onSelectionChanged([]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
      child: Row(
        children: [
          ...items.map((item) {
            final isSelected = selectedValues.contains(item.value);
            return Padding(
              padding: const EdgeInsets.only(right: AppTheme.spacingS),
              child: FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.icon != null) ...[
                      Icon(
                        item.icon,
                        size: 16,
                        color: isSelected
                            ? Colors.white
                            : AppTheme.textPrimary,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(item.label),
                  ],
                ),
                selected: isSelected,
                onSelected: (_) => _toggleSelection(item.value),
                selectedColor: AppTheme.primaryColor,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.lightBorderColor,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingS,
                  vertical: AppTheme.spacingXS,
                ),
              ),
            );
          }),
          if (showClearAll && selectedValues.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: AppTheme.spacingS),
              child: TextButton(
                onPressed: _clearAll,
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
