import '../errors/exceptions.dart';

/// Helper class for consistent error handling in data sources
/// Ensures NetworkException and AuthenticationException are properly preserved
class ErrorHandlerHelper {
  /// Handle exceptions in data sources, preserving NetworkException and AuthenticationException
  /// 
  /// Usage:
  /// ```dart
  /// try {
  ///   // API call
  /// } on ServerException {
  ///   rethrow;
  /// } on NetworkException {
  ///   rethrow;
  /// } on AuthenticationException {
  ///   rethrow;
  /// } catch (e) {
  ///   ErrorHandlerHelper.handleUnexpectedError(e, 'Operation name');
  /// }
  /// ```
  static Never handleUnexpectedError(dynamic e, String operationName) {
    // Preserve known exceptions
    if (e is NetworkException || 
        e is AuthenticationException || 
        e is ServerException ||
        e is AuthorizationException ||
        e is NotFoundException) {
      throw e;
    }
    
    // For unknown exceptions, wrap in ServerException with meaningful message
    final errorMessage = e.toString().contains('Exception')
        ? 'Failed to $operationName: ${e.toString()}'
        : 'Failed to $operationName: ${e.toString()}';
    throw ServerException(errorMessage);
  }
}
