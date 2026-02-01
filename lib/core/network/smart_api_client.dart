import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';
import '../session/session_manager.dart';

/// Request deduplication key generator
String _generateRequestKey(String method, String endpoint, Map<String, dynamic>? body, Map<String, String>? headers) {
  final bodyStr = body != null ? jsonEncode(body) : '';
  final headersStr = headers != null ? headers.toString() : '';
  return '$method:$endpoint:$bodyStr:$headersStr';
}

/// Smart API Client with:
/// - Request deduplication
/// - Automatic retry with exponential backoff
/// - Request throttling/debouncing
/// - Timeout handling
/// - Connectivity awareness
class SmartApiClient {
  final http.Client client;
  final String baseUrl;
  
  // Request deduplication: Track ongoing requests
  final Map<String, Completer<Map<String, dynamic>>> _pendingRequests = {};
  
  // Request throttling: Track last request time per endpoint
  final Map<String, DateTime> _lastRequestTime = {};
  final Map<String, Timer> _debounceTimers = {};
  
  // Retry configuration
  static const int _maxRetries = 3;
  static const Duration _baseRetryDelay = Duration(seconds: 1);
  static const Duration _throttleDuration = Duration(milliseconds: 300);
  static const Duration _debounceDuration = Duration(milliseconds: 500);
  
  SmartApiClient({
    http.Client? client,
    String? baseUrl,
  })  : client = client ?? http.Client(),
        baseUrl = baseUrl ?? ApiConstants.baseUrl;

  /// GET request with deduplication and caching
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    bool forceRefresh = false,
    Duration? cacheDuration,
  }) async {
    final requestKey = _generateRequestKey('GET', endpoint, queryParameters, headers);
    
    // Check for duplicate request
    if (!forceRefresh && _pendingRequests.containsKey(requestKey)) {
      print('🔄 Deduplicating GET request: $endpoint');
      return _pendingRequests[requestKey]!.future;
    }
    
    // Throttle rapid requests
    await _throttleRequest(requestKey);
    
    final completer = Completer<Map<String, dynamic>>();
    _pendingRequests[requestKey] = completer;
    
    try {
      final uri = Uri.parse('$baseUrl$endpoint').replace(
        queryParameters: queryParameters?.map((key, value) => 
          MapEntry(key, value.toString())),
      );
      
      final response = await _executeWithRetry(
        () => client.get(uri, headers: _buildHeaders(headers)),
        requestKey,
      );
      
      final result = _handleResponse(response);
      completer.complete(result);
      return result;
    } catch (e) {
      completer.completeError(e);
      rethrow;
    } finally {
      _pendingRequests.remove(requestKey);
    }
  }

  /// POST request with deduplication
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    bool allowDuplicate = false, // POST usually shouldn't deduplicate
  }) async {
    final requestKey = _generateRequestKey('POST', endpoint, body, headers);
    
    // Check for duplicate request (only if allowDuplicate is false)
    if (!allowDuplicate && _pendingRequests.containsKey(requestKey)) {
      print('🔄 Deduplicating POST request: $endpoint');
      return _pendingRequests[requestKey]!.future;
    }
    
    final completer = Completer<Map<String, dynamic>>();
    if (!allowDuplicate) {
      _pendingRequests[requestKey] = completer;
    }
    
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final jsonBody = body != null ? jsonEncode(body) : null;
      
      final response = await _executeWithRetry(
        () => client.post(uri, headers: _buildHeaders(headers), body: jsonBody),
        requestKey,
      );
      
      final result = _handleResponse(response);
      if (!allowDuplicate) completer.complete(result);
      return result;
    } catch (e) {
      if (!allowDuplicate) completer.completeError(e);
      rethrow;
    } finally {
      if (!allowDuplicate) {
        _pendingRequests.remove(requestKey);
      }
    }
  }

  /// PUT request
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final jsonBody = body != null ? jsonEncode(body) : null;
    
    final response = await _executeWithRetry(
      () => client.put(uri, headers: _buildHeaders(headers), body: jsonBody),
      _generateRequestKey('PUT', endpoint, body, headers),
    );
    
    return _handleResponse(response);
  }

  /// PATCH request
  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final jsonBody = body != null ? jsonEncode(body) : null;
    
    final response = await _executeWithRetry(
      () => client.patch(uri, headers: _buildHeaders(headers), body: jsonBody),
      _generateRequestKey('PATCH', endpoint, body, headers),
    );
    
    return _handleResponse(response);
  }

  /// DELETE request
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    
    final response = await _executeWithRetry(
      () => client.delete(uri, headers: _buildHeaders(headers)),
      _generateRequestKey('DELETE', endpoint, null, headers),
    );
    
    return _handleResponse(response);
  }

  /// Execute request with exponential backoff retry
  Future<http.Response> _executeWithRetry(
    Future<http.Response> Function() request,
    String requestKey,
  ) async {
    int attempt = 0;
    Exception? lastException;
    
    while (attempt < _maxRetries) {
      try {
        final response = await request().timeout(
          const Duration(milliseconds: ApiConstants.connectTimeout),
        );
        
        // Success - return immediately
        if (response.statusCode < 500 || attempt == _maxRetries - 1) {
          return response;
        }
        
        // Server error - retry
        lastException = ServerException('Server error: ${response.statusCode}');
      } on TimeoutException {
        lastException = NetworkException('Request timeout');
        if (attempt == _maxRetries - 1) break;
      } on NetworkException {
        lastException = NetworkException('Network error');
        if (attempt == _maxRetries - 1) break;
      } catch (e) {
        lastException = NetworkException('Unexpected error: ${e.toString()}');
        if (attempt == _maxRetries - 1) break;
      }
      
      // Exponential backoff
      attempt++;
      if (attempt < _maxRetries) {
        final delay = _baseRetryDelay * (1 << (attempt - 1)); // 1s, 2s, 4s
        print('🔄 Retrying request (attempt $attempt/$_maxRetries) after ${delay.inSeconds}s');
        await Future.delayed(delay);
      }
    }
    
    throw lastException ?? NetworkException('Request failed after $_maxRetries attempts');
  }

  /// Throttle rapid requests to same endpoint
  Future<void> _throttleRequest(String requestKey) async {
    final now = DateTime.now();
    final lastTime = _lastRequestTime[requestKey];
    
    if (lastTime != null) {
      final timeSinceLastRequest = now.difference(lastTime);
      if (timeSinceLastRequest < _throttleDuration) {
        final waitTime = _throttleDuration - timeSinceLastRequest;
        print('⏱️ Throttling request: waiting ${waitTime.inMilliseconds}ms');
        await Future.delayed(waitTime);
      }
    }
    
    _lastRequestTime[requestKey] = DateTime.now();
  }

  /// Debounce requests (useful for search/filter)
  Future<Map<String, dynamic>> getDebounced(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Duration? debounceDuration,
  }) async {
    final key = 'debounce:$endpoint';
    
    // Cancel previous debounce timer
    _debounceTimers[key]?.cancel();
    
    final completer = Completer<Map<String, dynamic>>();
    
    _debounceTimers[key] = Timer(
      debounceDuration ?? _debounceDuration,
      () async {
        try {
          final result = await get(endpoint, headers: headers, queryParameters: queryParameters);
          completer.complete(result);
        } catch (e) {
          completer.completeError(e);
        }
      },
    );
    
    return completer.future;
  }

  Map<String, String> _buildHeaders(Map<String, String>? additionalHeaders) {
    final headers = <String, String>{
      ApiConstants.contentTypeHeader: ApiConstants.contentTypeJson,
    };
    
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }
    
    return headers;
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body;
    
    if (_isHtmlResponse(body)) {
      throw ServerException(
        'Received HTML response instead of JSON. Base URL may be incorrect.',
      );
    }
    
    if (statusCode >= 200 && statusCode < 300) {
      if (body.isEmpty) {
        return {'success': true};
      }
      try {
        return jsonDecode(body) as Map<String, dynamic>;
      } catch (e) {
        throw ServerException('Invalid JSON response');
      }
    } else if (statusCode == 401) {
      SessionManager().handleAuthenticationError();
      throw AuthenticationException('Session expired. Please login again.');
    } else if (statusCode == 403) {
      throw AuthorizationException('Forbidden');
    } else if (statusCode == 404) {
      throw NotFoundException('Not found');
    } else {
      String errorMessage = 'Server error';
      try {
        if (body.isNotEmpty) {
          final json = jsonDecode(body) as Map<String, dynamic>;
          errorMessage = json['message'] as String? ?? 
                        json['error'] as String? ?? 
                        'Server error';
        }
      } catch (e) {
        errorMessage = 'Server error (Status: $statusCode)';
      }
      throw ServerException(errorMessage);
    }
  }

  bool _isHtmlResponse(String responseBody) {
    if (responseBody.isEmpty) return false;
    final lowerBody = responseBody.toLowerCase().trim();
    return lowerBody.startsWith('<!doctype html>') ||
           lowerBody.startsWith('<html') ||
           lowerBody.contains('parking') ||
           lowerBody.contains('domain');
  }

  void dispose() {
    _debounceTimers.values.forEach((timer) => timer.cancel());
    _debounceTimers.clear();
    _pendingRequests.clear();
    _lastRequestTime.clear();
    client.close();
  }
}
