import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';
import '../session/session_manager.dart';

class ApiClient {
  final http.Client client;
  final String baseUrl;
  
  ApiClient({
    http.Client? client,
    String? baseUrl,
  })  : client = client ?? http.Client(),
        baseUrl = baseUrl ?? ApiConstants.baseUrl;
  
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint').replace(
        queryParameters: queryParameters?.map((key, value) => 
          MapEntry(key, value.toString())),
      );
      
      final response = await client.get(
        uri,
        headers: _buildHeaders(headers),
      ).timeout(
        const Duration(milliseconds: ApiConstants.connectTimeout),
      );
      
      return _handleResponse(response);
    } on http.ClientException catch (e) {
      // Check for "Broken pipe" and connection errors in ClientException message
      final errorMessage = e.message.toLowerCase();
      if (errorMessage.contains('broken pipe') ||
          errorMessage.contains('connection closed') ||
          errorMessage.contains('connection') && errorMessage.contains('closed')) {
        throw NetworkException(
          'Network connection error. Please check your internet connection and try again.'
        );
      }
      throw NetworkException(e.message);
    } on TimeoutException {
      throw NetworkException(
        'Request timed out. Please check your internet connection and try again.'
      );
    } catch (e) {
      if (e is NetworkException || e is ServerException) {
        rethrow;
      }
      // Check for "Broken pipe" in error message
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('broken pipe') ||
          errorString.contains('connection closed')) {
        throw NetworkException(
          'Network connection error. Please check your internet connection and try again.'
        );
      }
      throw NetworkException('Network error: ${e.toString()}');
    }
  }
  
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      print('📡 ApiClient.post: Sending request');
      print('   Full URL: $uri');
      print('   Headers: ${_buildHeaders(headers)}');
      
      String? jsonBody;
      if (body != null) {
        jsonBody = jsonEncode(body);
        print('   📋 Request body keys: ${body.keys.toList()}');
        print('   📋 Request body (first 500 chars): ${jsonBody.length > 500 ? jsonBody.substring(0, 500) + "..." : jsonBody}');
        if (body.containsKey('seatConfiguration')) {
          print('   ✅ seatConfiguration in body: ${body['seatConfiguration']}');
        } else {
          print('   ⚠️ seatConfiguration NOT in body');
        }
      }
      
      final response = await client.post(
        uri,
        headers: _buildHeaders(headers),
        body: jsonBody,
      ).timeout(
        const Duration(milliseconds: ApiConstants.connectTimeout),
      );
      
      print('📥 ApiClient.post: Response received');
      print('   Status Code: ${response.statusCode}');
      
      return _handleResponse(response);
    } on TimeoutException {
      print('❌ ApiClient.post: TimeoutException');
      throw NetworkException('Request timeout: Connection timed out. Please check your internet connection and try again.');
    } on http.ClientException catch (e) {
      print('❌ ApiClient.post: ClientException');
      print('   Error: ${e.message}');
      throw NetworkException(e.message);
    } catch (e) {
      print('❌ ApiClient.post: Unexpected error');
      print('   Error type: ${e.runtimeType}');
      print('   Error: $e');
      // Re-throw known API exceptions so higher layers can handle them correctly
      if (e is NetworkException ||
          e is ServerException ||
          e is AuthenticationException ||
          e is AuthorizationException) {
        rethrow;
      }
      // Fallback: treat as generic network error
      throw NetworkException('Network error: ${e.toString()}');
    }
  }
  
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      
      final response = await client.put(
        uri,
        headers: _buildHeaders(headers),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(
        const Duration(milliseconds: ApiConstants.connectTimeout),
      );
      
      return _handleResponse(response);
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    } catch (e) {
      if (e is NetworkException || e is ServerException) {
        rethrow;
      }
      throw NetworkException('Network error: ${e.toString()}');
    }
  }
  
  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      
      final response = await client.patch(
        uri,
        headers: _buildHeaders(headers),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(
        const Duration(milliseconds: ApiConstants.connectTimeout),
      );
      
      return _handleResponse(response);
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    } catch (e) {
      if (e is NetworkException || e is ServerException) {
        rethrow;
      }
      throw NetworkException('Network error: ${e.toString()}');
    }
  }
  
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      
      final response = await client.delete(
        uri,
        headers: _buildHeaders(headers),
      ).timeout(
        const Duration(milliseconds: ApiConstants.connectTimeout),
      );
      
      return _handleResponse(response);
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    } catch (e) {
      if (e is NetworkException || e is ServerException) {
        rethrow;
      }
      throw NetworkException('Network error: ${e.toString()}');
    }
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
    
    // Check for HTML responses (parking pages, error pages)
    if (_isHtmlResponse(body)) {
      print('❌ CRITICAL: Got HTML response instead of JSON!');
      print('   Current base URL: $baseUrl');
      throw ServerException(
        'Received HTML response (parking page/error page) instead of JSON. '
        'This indicates the base URL is incorrect or the server is not accessible.\n'
        'Current base URL: $baseUrl\n'
        'Please update ApiConstants.baseUrl to your actual server IP address.\n'
        'Example: http://192.168.1.100:5000/api',
      );
    }
    
    if (statusCode >= 200 && statusCode < 300) {
      if (body.isEmpty) {
        return {'success': true};
      }
      try {
        final json = jsonDecode(body) as Map<String, dynamic>;
        return json;
      } catch (e) {
        throw ServerException('Invalid JSON response');
      }
    } else if (statusCode == 401) {
      // Handle token expiration globally
      print('🔐 ApiClient: 401 Unauthorized - Token expired or invalid');
      // Trigger session manager to handle logout
      SessionManager().handleAuthenticationError();
      throw AuthenticationException('Session expired. Please login again.');
    } else if (statusCode == 403) {
      throw AuthorizationException('Forbidden');
    } else if (statusCode == 404) {
      throw NotFoundException('Not found');
    } else {
      // Extract raw error message from response (for logging only)
      String rawErrorMessage = 'Server error';
      try {
        if (body.isNotEmpty) {
          final json = jsonDecode(body) as Map<String, dynamic>;
          // Try multiple possible error message fields
          rawErrorMessage = json['message'] as String? ?? 
                        json['error'] as String? ?? 
                        json['msg'] as String? ??
                        (json['errors'] != null ? json['errors'].toString() : null) ??
                        'Server error';
        }
      } catch (e) {
        // If JSON parsing fails, use status code
        rawErrorMessage = 'Server error (Status: $statusCode)';
      }
      
      // Log raw error for debugging (but don't expose to users)
      print('⚠️ Raw backend error (Status $statusCode): $rawErrorMessage');
      
      // Create a sanitized error message based on status code
      // The ErrorMessageSanitizer will further sanitize this in BLoCs
      String sanitizedMessage;
      if (statusCode >= 500) {
        sanitizedMessage = 'Server error occurred. Please try again later or contact support if the problem persists.';
      } else if (statusCode == 404) {
        sanitizedMessage = 'The requested item was not found.';
      } else if (statusCode == 403) {
        sanitizedMessage = 'You do not have permission to perform this action.';
      } else if (statusCode == 400) {
        // For 400 errors, try to extract user-friendly validation message
        // but sanitize it to remove technical details
        sanitizedMessage = _sanitize400Error(rawErrorMessage);
      } else {
        sanitizedMessage = 'An error occurred. Please try again.';
      }
      
      throw ServerException(sanitizedMessage);
    }
  }
  
  /// Sanitize 400 Bad Request errors to extract user-friendly messages
  String _sanitize400Error(String rawMessage) {
    final lowerMessage = rawMessage.toLowerCase();
    
    // Check for validation-like errors that might be user-actionable
    if (lowerMessage.contains('already exists') || lowerMessage.contains('duplicate')) {
      return 'This item already exists. Please use a different value.';
    }
    
    if (lowerMessage.contains('required') || lowerMessage.contains('missing')) {
      return 'Please fill in all required fields.';
    }
    
    if (lowerMessage.contains('invalid')) {
      return 'Invalid input. Please check your information and try again.';
    }
    
    // Remove technical details
    if (rawMessage.contains('Error:') || 
        rawMessage.contains('Exception:') ||
        rawMessage.contains('at ') ||
        rawMessage.length > 200) {
      return 'Invalid request. Please check your input and try again.';
    }
    
    // If message seems user-friendly and short, return as-is
    return rawMessage.length < 100 ? rawMessage : 'Invalid request. Please check your input and try again.';
  }

  /// Check if response is HTML (parking page, error page)
  bool _isHtmlResponse(String responseBody) {
    if (responseBody.isEmpty) return false;
    final lowerBody = responseBody.toLowerCase().trim();
    return lowerBody.startsWith('<!doctype html>') ||
           lowerBody.startsWith('<html') ||
           lowerBody.contains('<html>') ||
           lowerBody.contains('<!DOCTYPE HTML') ||
           lowerBody.contains('parking') ||
           lowerBody.contains('domain') ||
           lowerBody.contains('this domain may be for sale');
  }

  void dispose() {
    client.close();
  }
}

