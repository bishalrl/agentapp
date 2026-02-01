import 'package:flutter/material.dart';

/// Minimal scroll animation utilities
class ScrollAnimations {
  /// Animated list item builder with fade and slide
  static Widget fadeSlideItem({
    required BuildContext context,
    required int index,
    required Animation<double> animation,
    required Widget child,
    Offset beginOffset = const Offset(0, 0.1),
  }) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: beginOffset,
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
        ),
        child: child,
      ),
    );
  }

  /// Staggered animation for list items
  static List<Animation<double>> createStaggeredAnimations(
    AnimationController controller,
    int itemCount, {
    Duration interval = const Duration(milliseconds: 50),
  }) {
    final animations = <Animation<double>>[];
    for (int i = 0; i < itemCount; i++) {
      animations.add(
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              i * interval.inMilliseconds / controller.duration!.inMilliseconds,
              (i * interval.inMilliseconds + 200) / controller.duration!.inMilliseconds,
              curve: Curves.easeOutCubic,
            ),
          ),
        ),
      );
    }
    return animations;
  }
}

/// Animated list view with fade and slide
class AnimatedListView extends StatelessWidget {
  final List<Widget> children;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final Duration animationDuration;
  final Duration staggerDuration;

  const AnimatedListView({
    super.key,
    required this.children,
    this.controller,
    this.padding,
    this.animationDuration = const Duration(milliseconds: 300),
    this.staggerDuration = const Duration(milliseconds: 50),
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: padding,
      itemCount: children.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: animationDuration + (staggerDuration * index),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: children[index],
        );
      },
    );
  }
}
