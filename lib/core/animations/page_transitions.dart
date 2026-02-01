import 'package:flutter/material.dart';

/// Minimal page transition animations
class PageTransitions {
  /// Fade transition - minimal and smooth
  static PageRouteBuilder<T> fadeTransition<T extends Object?>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 200),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          child: child,
        );
      },
    );
  }

  /// Slide from right - minimal slide
  static PageRouteBuilder<T> slideTransition<T extends Object?>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 250),
    Offset begin = const Offset(1.0, 0.0),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: begin,
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  /// Scale transition - subtle zoom
  static PageRouteBuilder<T> scaleTransition<T extends Object?>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 200),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }
}
