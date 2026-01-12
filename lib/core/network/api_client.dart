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
      throw NetworkException(e.message);
    } catch (e) {
      if (e is NetworkException || e is ServerException) {
        rethrow;
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
      
      final response = await client.post(
        uri,
        headers: _buildHeaders(headers),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(
        const Duration(milliseconds: ApiConstants.connectTimeout),
      );
      
      print('📥 ApiClient.post: Response received');
      print('   Status Code: ${response.statusCode}');
      
      return _handleResponse(response);
    } on TimeoutException catch (e) {
      print('❌ ApiClient.post: TimeoutException');
      print('   Error: ${e.message ?? "Request timeout"}');
      throw NetworkException('Request timeout: ${e.message ?? "Connection timed out"}');
    } on http.ClientException catch (e) {
      print('❌ ApiClient.post: ClientException');
      print('   Error: ${e.message}');
      throw NetworkException(e.message);
    } catch (e) {
      print('❌ ApiClient.post: Unexpected error');
      print('   Error type: ${e.runtimeType}');
      print('   Error: $e');
      if (e is NetworkException || e is ServerException) {
        rethrow;
      }
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
      // Try to extract meaningful error message from response
      String errorMessage = 'Server error';
      try {
        if (body.isNotEmpty) {
          final json = jsonDecode(body) as Map<String, dynamic>;
          // Try multiple possible error message fields
          errorMessage = json['message'] as String? ?? 
                        json['error'] as String? ?? 
                        json['msg'] as String? ??
                        (json['errors'] != null ? json['errors'].toString() : null) ??
                        'Server error';
        }
      } catch (e) {
        // If JSON parsing fails, try to use the raw body if it's not too long
        if (body.isNotEmpty && body.length < 500) {
          errorMessage = 'Server error: $body';
        } else {
          errorMessage = 'Server error (Status: $statusCode)';
        }
      }
      
      // Provide more specific error messages based on status code
      if (statusCode >= 500) {
        errorMessage = 'Server error: $errorMessage. Please try again later or contact support.';
      } else if (statusCode >= 400) {
        errorMessage = 'Request error: $errorMessage';
      }
      
      throw ServerException(errorMessage);
    }
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

