import '../errors/failures.dart';
import '../session/session_manager.dart';

/// Utility class for handling authentication errors consistently
class AuthErrorHandler {
  /// Check if a failure is an authentication error
  static bool isAuthenticationError(Failure failure) {
    return failure is AuthenticationFailure;
  }

  /// Handle authentication error - delegates to SessionManager
  static Future<void> handleAuthenticationError() async {
    await SessionManager().handleAuthenticationError();
  }

  /// Get user-friendly error message for authentication errors
  static String getAuthErrorMessage(Failure failure) {
    if (failure is AuthenticationFailure) {
      final message = failure.message.toLowerCase();
      if (message.contains('expired') || message.contains('invalid')) {
        return 'Your session has expired. Please login again.';
      } else if (message.contains('unauthorized')) {
        return 'Authentication required. Please login again.';
      } else {
        return 'Authentication error. Please login again.';
      }
    }
    return failure.message;
  }
}
