import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';
import '../session/session_manager.dart';

class MultipartClient {
  final String baseUrl;

  MultipartClient({String? baseUrl})
      : baseUrl = baseUrl ?? ApiConstants.baseUrl;

  Future<Map<String, dynamic>> postMultipart({
    required String endpoint,
    required Map<String, String> fields,
    required Map<String, File> files,
    Map<String, String>? headers,
    String? token,
  }) async {
    try {
      print('📡 MultipartClient Request:');
      print('   Base URL: $baseUrl');
      print('   Endpoint: $endpoint');
      print('   Full URL: $baseUrl$endpoint');
      
      final uri = Uri.parse('$baseUrl$endpoint');
      final request = http.MultipartRequest('POST', uri);

      // Add text fields
      request.fields.addAll(fields);

      // Add files
      for (var entry in files.entries) {
        final file = entry.value;
        if (await file.exists()) {
          final fileStream = http.ByteStream(file.openRead());
          final fileLength = await file.length();
          final multipartFile = http.MultipartFile(
            entry.key,
            fileStream,
            fileLength,
            filename: file.path.split('/').last,
          );
          request.files.add(multipartFile);
        }
      }

      // Add headers first
      if (headers != null) {
        request.headers.addAll(headers);
      }
      // Add authorization header if token provided (overrides if in headers)
      if (token != null) {
        request.headers['Authorization'] = '${ApiConstants.bearerPrefix}$token';
      }

      // Don't set Content-Type manually - http package will set it with proper boundary
      // request.headers['Content-Type'] = 'multipart/form-data';

      final streamedResponse = await request.send().timeout(
        const Duration(milliseconds: ApiConstants.receiveTimeout),
      );

      final response = await http.Response.fromStream(streamedResponse);

      print('📡 MultipartClient Response:');
      print('   Status Code: ${response.statusCode}');
      print('   Headers: ${response.headers}');
      print('   Body: ${response.body}');

      // Check for HTML responses (parking pages, error pages)
      if (_isHtmlResponse(response.body)) {
        print('   ❌ CRITICAL: Got HTML response instead of JSON!');
        print('   This means the base URL is wrong or server is not accessible.');
        print('   Current base URL: $baseUrl');
        print('   Full URL: $baseUrl$endpoint');
        throw ServerException(
          '[MultipartClient] Received HTML response (parking page/error page) instead of JSON. '
          'This indicates the base URL is incorrect or the server is not accessible.\n'
          'Current base URL: $baseUrl\n'
          'Please update ApiConstants.baseUrl to your actual server IP address.\n'
          'Example: http://192.168.1.100:5000/api',
        );
      }

      // Handle redirects (3xx status codes) - check if redirect is to parking page
      if (response.statusCode >= 300 && response.statusCode < 400) {
        final location = response.headers['location'] ?? response.headers['Location'];
        print('   ⚠️ Redirect Response: ${response.statusCode}');
        print('   Location: $location');
        
        // Check if redirect is to a parking page
        if (location != null && _isParkingPageUrl(location)) {
          print('   ❌ CRITICAL: Redirect is to a parking page!');
          print('   This means the base URL is wrong.');
          throw ServerException(
            '[MultipartClient] Server redirected to a parking page. The base URL is incorrect.\n'
            'Current base URL: $baseUrl\n'
            'Redirect location: $location\n'
            'Please update ApiConstants.baseUrl to your actual server IP address.\n'
            'Example: http://192.168.1.100:5000/api',
          );
        }
        
        if (location != null && location.isNotEmpty) {
          print('   🔄 Following redirect to: $location');
          // Follow the redirect by creating a new request to the redirect location
          return await _followRedirect(
            redirectUrl: location,
            fields: fields,
            files: files,
            token: token,
          );
        } else {
          throw ServerException(
            '[MultipartClient] Server redirected the request but no location header found. '
            'Status: ${response.statusCode}',
          );
        }
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseBody = response.body;
        final parsed = _parseResponse(responseBody);
        print('   ✅ Response parsed successfully');
        // For 201 Created, return success with message
        if (response.statusCode == 201) {
          return {
            'success': true,
            'message': parsed['message'] as String? ?? 
              'Registration successful! We will review your documents and contact you by email after verification.',
          };
        }
        return parsed;
      } else {
        print('   ❌ Error Response: ${response.statusCode}');
        print('   Error Body: ${response.body}');
        final errorBody = _parseResponse(response.body);
        String errorMessage;
        
        // Try to extract error message from response
        if (errorBody['message'] != null && errorBody['message'].toString().isNotEmpty) {
          errorMessage = errorBody['message'].toString();
        } else if (response.body.isNotEmpty) {
          errorMessage = response.body;
        } else {
          // Provide meaningful error based on status code
          switch (response.statusCode) {
            case 302:
            case 301:
            case 307:
            case 308:
              final location = response.headers['location'] ?? response.headers['Location'];
              errorMessage = 'Server redirected the request (${response.statusCode}). '
                  'This may indicate an API endpoint configuration issue. '
                  'Location: ${location ?? 'Unknown'}';
              break;
            case 400:
              errorMessage = 'Bad request. Please check your input data.';
              break;
            case 401:
              // Handle token expiration globally
              print('🔐 MultipartClient: 401 Unauthorized - Token expired or invalid');
              // Trigger session manager to handle logout
              SessionManager().handleAuthenticationError();
              errorMessage = 'Session expired. Please login again.';
              break;
            case 403:
              errorMessage = 'Forbidden. You do not have permission to perform this action.';
              break;
            case 404:
              errorMessage = 'Endpoint not found. Please check the API endpoint.';
              break;
            case 500:
              errorMessage = 'Internal server error. Please try again later.';
              break;
            default:
              errorMessage = 'Request failed with status ${response.statusCode}';
          }
        }
        
        print('   Error Message: $errorMessage');
        throw ServerException('[MultipartClient] $errorMessage');
      }
    } on http.ClientException catch (e) {
      print('   ❌ Network Error: ${e.message}');
      throw NetworkException(e.message);
    } on NetworkException {
      rethrow;
    } on AuthenticationException {
      rethrow;
    } on ServerException catch (e) {
      print('   ❌ ServerException rethrown: ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      print('   ❌ Unexpected Error: $e');
      print('   StackTrace: $stackTrace');
      throw ServerException('[MultipartClient] Failed to send request: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> putMultipart({
    required String endpoint,
    required Map<String, String> fields,
    required Map<String, File> files,
    Map<String, String>? headers,
    String? token,
  }) async {
    try {
      print('📡 MultipartClient PUT Request:');
      print('   Base URL: $baseUrl');
      print('   Endpoint: $endpoint');
      print('   Full URL: $baseUrl$endpoint');
      
      final uri = Uri.parse('$baseUrl$endpoint');
      final request = http.MultipartRequest('PUT', uri);

      // Add text fields
      request.fields.addAll(fields);

      // Add files
      for (var entry in files.entries) {
        final file = entry.value;
        if (await file.exists()) {
          final fileStream = http.ByteStream(file.openRead());
          final fileLength = await file.length();
          final multipartFile = http.MultipartFile(
            entry.key,
            fileStream,
            fileLength,
            filename: file.path.split('/').last,
          );
          request.files.add(multipartFile);
        }
      }

      // Add headers
      if (headers != null) {
        request.headers.addAll(headers);
      }
      // Add authorization header if token provided
      if (token != null) {
        request.headers['Authorization'] = '${ApiConstants.bearerPrefix}$token';
      }

      final streamedResponse = await request.send().timeout(
        const Duration(milliseconds: ApiConstants.receiveTimeout),
      );

      final response = await http.Response.fromStream(streamedResponse);

      print('📡 MultipartClient PUT Response:');
      print('   Status Code: ${response.statusCode}');
      print('   Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final parsed = _parseResponse(response.body);
        return parsed;
      } else {
        final errorBody = _parseResponse(response.body);
        String errorMessage = errorBody['message'] as String? ?? 
            'Request failed with status ${response.statusCode}';
        throw ServerException('[MultipartClient] $errorMessage');
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('[MultipartClient] Failed to send PUT request: ${e.toString()}');
    }
  }

  /// Follow a redirect by making a new request to the redirect location
  Future<Map<String, dynamic>> _followRedirect({
    required String redirectUrl,
    required Map<String, String> fields,
    required Map<String, File> files,
    String? token,
  }) async {
    try {
      final redirectUri = Uri.parse(redirectUrl);
      final request = http.MultipartRequest('POST', redirectUri);

      // Add text fields
      request.fields.addAll(fields);

      // Add files (need to re-read them)
      for (var entry in files.entries) {
        final file = entry.value;
        if (await file.exists()) {
          final fileStream = http.ByteStream(file.openRead());
          final fileLength = await file.length();
          final multipartFile = http.MultipartFile(
            entry.key,
            fileStream,
            fileLength,
            filename: file.path.split('/').last,
          );
          request.files.add(multipartFile);
        }
      }

      // Add authorization header if token provided
      if (token != null) {
        request.headers['Authorization'] = '${ApiConstants.bearerPrefix}$token';
      }

      // Don't set Content-Type for multipart - let the library handle it
      // request.headers['Content-Type'] = 'multipart/form-data';

      print('   📤 Sending redirected request to: $redirectUrl');
      final streamedResponse = await request.send().timeout(
        const Duration(milliseconds: ApiConstants.receiveTimeout),
      );

      final response = await http.Response.fromStream(streamedResponse);

      print('   📥 Redirected Response:');
      print('   Status Code: ${response.statusCode}');
      print('   Headers: ${response.headers}');
      print('   Body: ${response.body}');

      // Check for HTML responses (parking pages)
      if (_isHtmlResponse(response.body)) {
        print('   ❌ CRITICAL: Redirected to HTML page (parking page)!');
        throw ServerException(
          '[MultipartClient] Redirected to HTML page (parking page) instead of JSON. '
          'The base URL is incorrect.\n'
          'Redirect URL: $redirectUrl\n'
          'Please update ApiConstants.baseUrl to your actual server IP address.',
        );
      }

      // Check for another redirect (shouldn't happen, but handle it)
      if (response.statusCode >= 300 && response.statusCode < 400) {
        final location = response.headers['location'] ?? response.headers['Location'];
        if (location != null && _isParkingPageUrl(location)) {
          print('   ❌ CRITICAL: Another redirect to parking page detected!');
          throw ServerException(
            '[MultipartClient] Multiple redirects detected, ending at parking page. '
            'The base URL is incorrect.\n'
            'Please update ApiConstants.baseUrl to your actual server IP address.',
          );
        }
        if (location != null && location.isNotEmpty) {
          print('   ⚠️ Another redirect detected, following: $location');
          return await _followRedirect(
            redirectUrl: location,
            fields: fields,
            files: files,
            token: token,
          );
        }
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseBody = response.body;
        final parsed = _parseResponse(responseBody);
        print('   ✅ Redirected request successful');
        // For 201 Created, return success with message
        if (response.statusCode == 201) {
          return {
            'success': true,
            'message': parsed['message'] as String? ?? 
              'Registration successful! We will review your documents and contact you by email after verification.',
          };
        }
        return parsed;
      } else {
        // Handle error from redirected request
        final errorBody = _parseResponse(response.body);
        String errorMessage;
        
        if (errorBody['message'] != null && errorBody['message'].toString().isNotEmpty) {
          errorMessage = errorBody['message'].toString();
        } else if (response.body.isNotEmpty) {
          errorMessage = response.body;
        } else {
          errorMessage = 'Request failed with status ${response.statusCode} after redirect';
        }
        
        print('   ❌ Redirected request failed: $errorMessage');
        throw ServerException('[MultipartClient] $errorMessage');
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      print('   ❌ Error following redirect: $e');
      throw ServerException('[MultipartClient] Failed to follow redirect: ${e.toString()}');
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

  /// Check if URL is a parking page
  bool _isParkingPageUrl(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('ww25.') ||
           lowerUrl.contains('ww26.') ||
           lowerUrl.contains('parking') ||
           lowerUrl.contains('domain') ||
           lowerUrl.contains('for-sale');
  }

  Map<String, dynamic> _parseResponse(String responseBody) {
    try {
      if (responseBody.isEmpty) {
        return {
          'success': true,
          'message': 'Registration successful! We will review your documents and contact you by email after verification.',
        };
      }
      // Try to parse as JSON
      final decoded = jsonDecode(responseBody) as Map<String, dynamic>;
      return decoded;
    } catch (e) {
      // If not JSON, treat as plain text message
      return {
        'success': true,
        'message': responseBody,
      };
    }
  }
}

