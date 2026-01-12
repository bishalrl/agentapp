import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// A widget that handles back button press with double-tap-to-exit functionality
/// 
/// Usage:
/// ```dart
/// BackButtonHandler(
///   child: YourWidget(),
///   onExit: () {
///     // Optional: Custom exit logic
///   },
/// )
/// ```
class BackButtonHandler extends StatefulWidget {
  final Widget child;
  final VoidCallback? onExit;
  final bool enableDoubleBackToExit;
  final String? exitMessage;
  final Duration exitDuration;

  const BackButtonHandler({
    super.key,
    required this.child,
    this.onExit,
    this.enableDoubleBackToExit = true,
    this.exitMessage,
    this.exitDuration = const Duration(seconds: 2),
  });

  @override
  State<BackButtonHandler> createState() => _BackButtonHandlerState();
}

class _BackButtonHandlerState extends State<BackButtonHandler> {
  DateTime? _lastBackPressTime;
  bool _isExiting = false;

  Future<bool> _onWillPop() async {
    // First, check if we can navigate back in the app
    if (context.canPop()) {
      // We can navigate back, so allow the pop to happen naturally
      return true; // Allow pop
    }

    // If we can't navigate back and double back to exit is disabled, 
    // just allow normal back behavior (which might exit)
    if (!widget.enableDoubleBackToExit) {
      widget.onExit?.call();
      return true;
    }

    // We're at the root and double back to exit is enabled
    final now = DateTime.now();
    
    // Check if we should exit
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > widget.exitDuration) {
      // First back press - show message
      _lastBackPressTime = now;
      _showExitMessage();
      return false; // Prevent exit
    } else {
      // Second back press within duration - exit
      widget.onExit?.call();
      _exitApp();
      return true; // Allow exit
    }
  }

  void _showExitMessage() {
    if (_isExiting) return;
    
    _isExiting = true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.exitMessage ?? 'Press back again to exit',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        duration: widget.exitDuration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: Colors.grey[800],
      ),
    );
    
    // Reset flag after duration
    Future.delayed(widget.exitDuration, () {
      if (mounted) {
        setState(() {
          _isExiting = false;
        });
      }
    });
  }

  void _exitApp() {
    if (Platform.isAndroid) {
      // On Android, use SystemNavigator.pop() to exit
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      // iOS doesn't allow programmatic exit, but we can try
      // In practice, iOS apps stay in background
      exit(0);
    } else {
      // For other platforms
      exit(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            // If we can pop, pop the navigation stack
            if (context.canPop()) {
              context.pop();
            } else {
              // Can't pop, so exit the app
              // (This only happens if double back to exit is disabled)
              _exitApp();
            }
          }
          // If shouldPop is false, we've already shown the exit message
          // and prevented the exit, so do nothing
        }
      },
      child: widget.child,
    );
  }
}

/// A helper widget for pages that should exit the app on double back press
class ExitOnDoubleBack extends StatelessWidget {
  final Widget child;
  final String? message;

  const ExitOnDoubleBack({
    super.key,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return BackButtonHandler(
      enableDoubleBackToExit: true,
      exitMessage: message ?? 'Press back again to exit',
      child: child,
      onExit: () {
        // Exit logic is handled in BackButtonHandler
      },
    );
  }
}

