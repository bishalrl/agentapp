import '../errors/failures.dart';

/// Centralized error message sanitizer
/// Converts backend/technical errors to user-friendly messages
/// Prevents exposure of sensitive information
class ErrorMessageSanitizer {
  /// Sanitize error message based on failure type
  /// Returns user-friendly message without sensitive information
  static String sanitize(Failure failure) {
    if (failure is AuthenticationFailure) {
      return _sanitizeAuthError(failure.message);
    } else if (failure is NetworkFailure) {
      return _sanitizeNetworkError(failure.message);
    } else if (failure is ServerFailure) {
      return _sanitizeServerError(failure.message);
    } else if (failure is ValidationFailure) {
      return _sanitizeValidationError(failure.message);
    } else if (failure is AuthorizationFailure) {
      return 'You do not have permission to perform this action.';
    } else if (failure is NotFoundFailure) {
      return 'The requested item was not found.';
    } else if (failure is CacheFailure) {
      return 'Unable to load cached data. Please try again.';
    } else {
      // Generic fallback for unknown errors
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Sanitize authentication errors
  static String _sanitizeAuthError(String message) {
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('invalid') && 
        (lowerMessage.contains('email') || lowerMessage.contains('password') || lowerMessage.contains('credentials'))) {
      return 'Invalid email or password. Please try again.';
    }
    
    if (lowerMessage.contains('expired') || lowerMessage.contains('token')) {
      return 'Your session has expired. Please login again.';
    }
    
    if (lowerMessage.contains('unauthorized') || lowerMessage.contains('401')) {
      return 'Authentication required. Please login again.';
    }
    
    // Generic auth error
    return 'Authentication failed. Please login again.';
  }

  /// Sanitize network errors
  static String _sanitizeNetworkError(String message) {
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('no route to host') || 
        lowerMessage.contains('connection refused') ||
        lowerMessage.contains('failed host lookup') ||
        lowerMessage.contains('name resolution')) {
      return 'Unable to connect to server. Please check your internet connection.';
    }
    
    if (lowerMessage.contains('timeout') || lowerMessage.contains('timed out')) {
      return 'Connection timeout. Please check your internet connection and try again.';
    }
    
    if (lowerMessage.contains('no internet') || 
        lowerMessage.contains('network is unreachable') ||
        lowerMessage.contains('socket exception')) {
      return 'No internet connection. Please check your network settings.';
    }
    
    // Generic network error
    return 'Network error. Please check your internet connection and try again.';
  }

  /// Sanitize server errors - CRITICAL: Remove all technical details
  static String _sanitizeServerError(String message) {
    final lowerMessage = message.toLowerCase();
    
    // Check for common error patterns and provide user-friendly messages
    if (lowerMessage.contains('500') || 
        lowerMessage.contains('internal server error') ||
        lowerMessage.contains('database') ||
        lowerMessage.contains('sql') ||
        lowerMessage.contains('query') ||
        lowerMessage.contains('exception') ||
        lowerMessage.contains('error at') ||
        lowerMessage.contains('stack trace') ||
        lowerMessage.contains('traceback')) {
      return 'Server error occurred. Please try again later or contact support if the problem persists.';
    }
    
    if (lowerMessage.contains('503') || lowerMessage.contains('service unavailable')) {
      return 'Service temporarily unavailable. Please try again in a few moments.';
    }
    
    if (lowerMessage.contains('502') || lowerMessage.contains('bad gateway')) {
      return 'Service temporarily unavailable. Please try again later.';
    }
    
    if (lowerMessage.contains('504') || lowerMessage.contains('gateway timeout')) {
      return 'Request timeout. Please try again.';
    }
    
    // Check for validation-like errors that might be user-actionable
    if (lowerMessage.contains('already exists') || lowerMessage.contains('duplicate')) {
      return 'This item already exists. Please use a different value.';
    }
    
    if (lowerMessage.contains('not found') || lowerMessage.contains('404')) {
      return 'The requested item was not found.';
    }
    
    if (lowerMessage.contains('forbidden') || lowerMessage.contains('403')) {
      return 'You do not have permission to perform this action.';
    }
    
    if (lowerMessage.contains('bad request') || lowerMessage.contains('400')) {
      // Try to extract user-friendly part if it's a validation error
      if (lowerMessage.contains('required') || 
          lowerMessage.contains('invalid') ||
          lowerMessage.contains('must be')) {
        // Extract the field name if possible, but sanitize it
        final regex = RegExp(r'(?:field|parameter|property)\s+(\w+)', caseSensitive: false);
        final fieldMatch = regex.firstMatch(message);
        if (fieldMatch != null) {
          final field = fieldMatch.group(1);
          if (field != null) {
            return 'Invalid ${_formatFieldName(field)}. Please check your input.';
          }
        }
        return 'Invalid input. Please check your information and try again.';
      }
      return 'Invalid request. Please check your input and try again.';
    }
    
    // Remove any technical details, stack traces, file paths, etc.
    // Check for patterns that indicate technical errors
    if (_containsTechnicalDetails(message)) {
      return 'An error occurred while processing your request. Please try again later.';
    }
    
    // If message seems user-friendly already, return as-is but limit length
    if (message.length > 200) {
      return 'An error occurred. Please try again.';
    }
    
    // Last resort: return a generic message
    return 'An error occurred. Please try again later.';
  }

  /// Sanitize validation errors
  static String _sanitizeValidationError(String message) {
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('required')) {
      final regex = RegExp(r'(\w+)\s+is\s+required', caseSensitive: false);
      final fieldMatch = regex.firstMatch(message);
      if (fieldMatch != null) {
        final field = fieldMatch.group(1);
        if (field != null) {
          return '${_formatFieldName(field)} is required.';
        }
      }
      return 'Please fill in all required fields.';
    }
    
    if (lowerMessage.contains('invalid')) {
      final regex = RegExp(r'invalid\s+(\w+)', caseSensitive: false);
      final fieldMatch = regex.firstMatch(message);
      if (fieldMatch != null) {
        final field = fieldMatch.group(1);
        if (field != null) {
          return 'Invalid ${_formatFieldName(field)}. Please check your input.';
        }
      }
      return 'Invalid input. Please check your information.';
    }
    
    // Return validation message as-is if it seems user-friendly
    if (message.length < 100 && !_containsTechnicalDetails(message)) {
      return message;
    }
    
    return 'Invalid input. Please check your information.';
  }

  /// Sanitize raw server/API message without a Failure object (e.g. in repositories).
  /// Use when creating ServerFailure so stored message is never backend/API text.
  static String sanitizeRawServerMessage(String message) {
    if (message.isEmpty) return getGenericErrorMessage();
    return _sanitizeServerError(message);
  }

  /// Check if message contains technical details that should be hidden
  static bool _containsTechnicalDetails(String message) {
    final lowerMessage = message.toLowerCase();

    // Internal/API/backend phrasing - never show to user
    if (lowerMessage.contains('exception') ||
        lowerMessage.contains('datasource') ||
        lowerMessage.contains('repository') ||
        lowerMessage.contains('remote_data_source') ||
        lowerMessage.contains('api') ||
        lowerMessage.contains('endpoint') ||
        lowerMessage.contains('error at') ||
        lowerMessage.contains('authremotedatasource') ||
        lowerMessage.contains('serverexception') ||
        lowerMessage.contains('e.tostring') ||
        lowerMessage.contains('unexpected error:')) {
      return true;
    }
    // "failed to" often prefixes internal/backend messages
    if (lowerMessage.contains('failed to')) return true;

    // Check for common technical patterns
    return lowerMessage.contains('error:') ||
           lowerMessage.contains('exception:') ||
           lowerMessage.contains('at ') ||
           lowerMessage.contains('file:') ||
           lowerMessage.contains('line ') ||
           lowerMessage.contains('stack') ||
           lowerMessage.contains('traceback') ||
           lowerMessage.contains('c:\\') ||
           lowerMessage.contains('/home/') ||
           lowerMessage.contains('/var/') ||
           lowerMessage.contains('node_modules') ||
           lowerMessage.contains('undefined') ||
           lowerMessage.contains('null pointer') ||
           lowerMessage.contains('typeerror') ||
           lowerMessage.contains('referenceerror') ||
           RegExp(r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}').hasMatch(message) || // IP addresses
           RegExp(r'[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}', caseSensitive: false).hasMatch(message); // UUIDs
  }

  /// Format field names to be more user-friendly
  static String _formatFieldName(String field) {
    // Convert camelCase/snake_case to Title Case
    return field
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty 
            ? '' 
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ')
        .trim();
  }

  /// Get a generic error message for unexpected errors
  static String getGenericErrorMessage() {
    return 'An unexpected error occurred. Please try again.';
  }

  /// Get a generic server error message
  static String getServerErrorMessage() {
    return 'Server error occurred. Please try again later or contact support if the problem persists.';
  }

  /// Get a generic network error message
  static String getNetworkErrorMessage() {
    return 'Network error. Please check your internet connection and try again.';
  }
}
