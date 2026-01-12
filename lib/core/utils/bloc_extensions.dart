import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Extension to safely add events to BLoCs
/// Prevents "Cannot add new events after calling close" errors
extension SafeBlocExtension on BlocBase {
  /// Safely adds an event to the BLoC
  /// Returns true if the event was added, false if the BLoC is closed
  bool safeAdd(dynamic event) {
    if (isClosed) {
      print('⚠️ Attempted to add event to closed BLoC: ${runtimeType}');
      print('   Event: $event');
      return false;
    }
    try {
      if (this is Bloc) {
        (this as Bloc).add(event);
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error adding event to BLoC ${runtimeType}: $e');
      print('   Event: $event');
      return false;
    }
  }
}

/// Extension on BuildContext to safely read and add events to BLoCs
extension SafeBlocContextExtension on BuildContext {
  /// Safely adds an event to a BLoC
  /// Returns true if the event was added, false if the BLoC is closed or not found
  bool safeAddEvent<T extends BlocBase>(T bloc, dynamic event) {
    try {
      if (bloc.isClosed) {
        print('⚠️ Attempted to add event to closed BLoC: ${bloc.runtimeType}');
        return false;
      }
      if (bloc is Bloc) {
        bloc.add(event);
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error adding event to BLoC ${bloc.runtimeType}: $e');
      return false;
    }
  }
}

