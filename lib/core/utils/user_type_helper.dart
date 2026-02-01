import '../utils/result.dart';
import '../../features/authentication/domain/usecases/get_stored_session_type.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../injection/injection.dart' as di;

/// Helper class to check user type/session type
class UserTypeHelper {
  /// Check if current user is a beta agent
  /// Returns true if session type is 'betaAgent', false otherwise
  static Future<bool> isBetaAgent() async {
    try {
      final getStoredSessionType = GetStoredSessionType(di.sl<AuthRepository>());
      final result = await getStoredSessionType();
      if (result is Success<String?>) {
        return result.data == 'betaAgent';
      }
      return false;
    } catch (e) {
      print('⚠️ UserTypeHelper.isBetaAgent: Error checking session type: $e');
      return false;
    }
  }

  /// Check if current user is a counter (not beta agent)
  /// Returns true if session type is 'counter', false otherwise
  static Future<bool> isCounter() async {
    try {
      final getStoredSessionType = GetStoredSessionType(di.sl<AuthRepository>());
      final result = await getStoredSessionType();
      if (result is Success<String?>) {
        return result.data == 'counter';
      }
      return false;
    } catch (e) {
      print('⚠️ UserTypeHelper.isCounter: Error checking session type: $e');
      return false;
    }
  }

  /// Get current session type
  /// Returns 'counter', 'betaAgent', 'driver', or null
  static Future<String?> getSessionType() async {
    try {
      final getStoredSessionType = GetStoredSessionType(di.sl<AuthRepository>());
      final result = await getStoredSessionType();
      if (result is Success<String?>) {
        return result.data;
      }
      return null;
    } catch (e) {
      print('⚠️ UserTypeHelper.getSessionType: Error getting session type: $e');
      return null;
    }
  }
}
