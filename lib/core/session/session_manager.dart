import 'package:go_router/go_router.dart';
import '../injection/injection.dart' as di;
import '../utils/result.dart';
import '../../features/authentication/domain/usecases/logout.dart';
import '../../features/authentication/domain/usecases/clear_token.dart';
/// Centralized session manager for handling authentication state
/// and token expiration
class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  bool _isLoggingOut = false;
  GoRouter? _router;

  /// Initialize the session manager with router
  void initialize(GoRouter router) {
    _router = router;
  }

  /// Handle authentication error (401) - clears token and redirects to login
  Future<void> handleAuthenticationError() async {
    if (_isLoggingOut) return; // Prevent multiple simultaneous logouts
    
    _isLoggingOut = true;
    
    try {
      // Clear token from storage
      final clearToken = di.sl<ClearToken>();
      final clearResult = await clearToken();
      if (clearResult is Error<void>) {
        print('⚠️ SessionManager: Failed to clear token: ${(clearResult as Error<void>).failure.message}');
      }
      
      // Logout (clears auth state)
      final logout = di.sl<Logout>();
      final logoutResult = await logout();
      if (logoutResult is Error<void>) {
        print('⚠️ SessionManager: Failed to logout: ${(logoutResult as Error<void>).failure.message}');
      }
      
      // Navigate to login page
      // Use a small delay to ensure router is ready
      await Future.delayed(const Duration(milliseconds: 200));
      if (_router != null) {
        try {
          // Use go() to replace entire navigation stack
          // This will work even without BuildContext
          _router!.go('/login');
          print('✅ SessionManager: Redirected to login page');
        } catch (e) {
          print('⚠️ SessionManager: Could not navigate to login: $e');
          // Fallback: Try using the router's navigator key if available
          try {
            final navigatorKey = _router!.routerDelegate.navigatorKey;
            if (navigatorKey.currentContext != null) {
              navigatorKey.currentContext!.go('/login');
            }
          } catch (e2) {
            print('⚠️ SessionManager: Fallback navigation also failed: $e2');
          }
        }
      }
    } catch (e) {
      print('❌ SessionManager.handleAuthenticationError: Error: $e');
    } finally {
      _isLoggingOut = false;
    }
  }

  /// Check if currently logging out
  bool get isLoggingOut => _isLoggingOut;
}
