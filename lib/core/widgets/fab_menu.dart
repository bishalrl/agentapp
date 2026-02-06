import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// FAB menu item model.
class FABMenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const FABMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
}

/// Expandable FAB with multiple actions, smooth animations, and overlay backdrop.
class FABMenu extends StatefulWidget {
  final IconData mainIcon;
  final List<FABMenuItem> items;
  final Color? backgroundColor;

  const FABMenu({
    super.key,
    this.mainIcon = Icons.add,
    required this.items,
    this.backgroundColor,
  });

  @override
  State<FABMenu> createState() => _FABMenuState();
}

class _FABMenuState extends State<FABMenu>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _rotateAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
        HapticFeedback.mediumImpact();
      } else {
        _controller.reverse();
        HapticFeedback.lightImpact();
      }
    });
  }

  void _onItemTap(FABMenuItem item) {
    _toggleMenu();
    Future.delayed(const Duration(milliseconds: 150), () {
      item.onTap();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = widget.backgroundColor ?? theme.colorScheme.primary;

    return Stack(
      children: [
        // Backdrop
        if (_isExpanded)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleMenu,
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
          ),

        // Menu items
        ...widget.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final reverseIndex = widget.items.length - index - 1;

          return Positioned(
            right: 16,
            bottom: 80 + (reverseIndex * 60.0),
            child: ScaleTransition(
              scale: _expandAnimation,
              child: FadeTransition(
                opacity: _expandAnimation,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _onItemTap(item),
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingM,
                        vertical: AppTheme.spacingS,
                      ),
                      decoration: BoxDecoration(
                        color: item.color ?? bgColor,
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: AppTheme.spacingS),
                          Text(
                            item.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),

        // Main FAB
        Positioned(
          right: 16,
          bottom: 16,
          child: RotationTransition(
            turns: _rotateAnimation,
            child: FloatingActionButton(
              onPressed: _toggleMenu,
              backgroundColor: bgColor,
              child: Icon(
                _isExpanded ? Icons.close : widget.mainIcon,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
