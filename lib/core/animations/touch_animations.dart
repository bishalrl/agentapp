import 'package:flutter/material.dart';

/// Minimal touch feedback animations
class TouchAnimations {
  /// Scale animation for tap feedback
  static Widget scaleOnTap({
    required Widget child,
    required VoidCallback onTap,
    double scale = 0.98,
    Duration duration = const Duration(milliseconds: 100),
  }) {
    return _ScaleOnTap(
      scale: scale,
      duration: duration,
      onTap: onTap,
      child: child,
    );
  }

  /// Ripple effect with minimal animation
  static Widget rippleEffect({
    required Widget child,
    required VoidCallback onTap,
    Color? rippleColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: rippleColor?.withOpacity(0.1),
        highlightColor: rippleColor?.withOpacity(0.05),
        child: child,
      ),
    );
  }
}

class _ScaleOnTap extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double scale;
  final Duration duration;

  const _ScaleOnTap({
    required this.child,
    required this.onTap,
    this.scale = 0.98,
    this.duration = const Duration(milliseconds: 100),
  });

  @override
  State<_ScaleOnTap> createState() => _ScaleOnTapState();
}

class _ScaleOnTapState extends State<_ScaleOnTap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scale,
    ).animate(
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

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
