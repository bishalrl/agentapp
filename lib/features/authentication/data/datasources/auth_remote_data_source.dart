import 'dart:async';
import 'dart:io';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/multipart_client.dart';
import '../models/auth_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthModel> login(String email, String password);
  Future<void> changePassword(String currentPassword, String newPassword, String token);
  Future<void> forgotPassword(String email);
  Future<void> resetPassword(String token, String newPassword);
  Future<AuthModel> signup({
    required String agencyName,
    required String ownerName,
    required String address,
    required String districtProvince,
    required String primaryContact,
    required String email,
    required String officeLocation,
    required String officeOpenTime,
    required String officeCloseTime,
    required int numberOfEmployees,
    required bool hasDeviceAccess,
    required bool hasInternetAccess,
    required String preferredBookingMethod,
    required String password,
    required File citizenshipFile,
    required File photoFile,
    String? panVatNumber,
    String? alternateContact,
    String? whatsappViber,
    File? panFile,
    File? registrationFile,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;
  final MultipartClient multipartClient;

  AuthRemoteDataSourceImpl(this.apiClient, this.multipartClient);

  @override
  Future<AuthModel> login(String email, String password) async {
    try {
      print('📤 AuthRemoteDataSource.login: Sending request');
      print('   Email: $email');
      print('   Endpoint: ${ApiConstants.counterLogin}');
      final response = await apiClient.post(
        ApiConstants.counterLogin,
        body: {
          'email': email,
          'password': password,
        },
      );
      print('📥 AuthRemoteDataSource.login: Response received');
      print('   Response keys: ${response.keys}');
      print('   Response: $response');
      print('   mustChangePassword from API: ${response['mustChangePassword']}');

      // Check for error responses first (even if status code is 200)
      if (response['success'] == false || (response['message'] != null && response['token'] == null)) {
        final errorMsg = response['message'] as String? ?? 'Invalid email or password';
        print('   ❌ Login failed: $errorMsg');
        print('   Response indicates failure: success=${response['success']}, message=$errorMsg');
        // Check if it's an authentication error
        final msgLower = errorMsg.toLowerCase();
        if (msgLower.contains('invalid') || 
            msgLower.contains('wrong') || 
            msgLower.contains('incorrect') ||
            msgLower.contains('email') ||
            msgLower.contains('password') ||
            msgLower.contains('credential')) {
          throw AuthenticationException(errorMsg);
        }
        throw ServerException(errorMsg);
      }

      // Handle different response formats
      // Format 1: Direct format { token, agent/counter, mustChangePassword }
      if (response['token'] != null && (response['agent'] != null || response['counter'] != null)) {
        print('   ✅ Parsing direct response format');
        final mustChangePassword = response['mustChangePassword'] as bool?;
        print('   mustChangePassword value: $mustChangePassword (type: ${mustChangePassword.runtimeType})');
        return AuthModel.fromJson(response);
      } 
      // Format 2: Wrapped format { success, message, token, mustChangePassword, data: { agent/counter } }
      else if (response['success'] == true && response['data'] != null) {
        print('   ✅ Parsing wrapped response format');
        // Merge top-level token and mustChangePassword with data object
        final data = response['data'] as Map<String, dynamic>;
        final mustChangePassword = response['mustChangePassword'] as bool? ?? false;
        print('   mustChangePassword from top level: $mustChangePassword');
        final mergedData = {
          ...data,
          'token': response['token'], // Token is at top level
          'mustChangePassword': mustChangePassword,
        };
        print('   Merged data keys: ${mergedData.keys}');
        print('   Merged mustChangePassword: ${mergedData['mustChangePassword']}');
        return AuthModel.fromJson(mergedData);
      } 
      // Format 3: Token at top level, agent/counter in data
      else if (response['token'] != null && response['data'] != null) {
        print('   ✅ Parsing format with token at top level and data nested');
        final data = response['data'] as Map<String, dynamic>;
        final mergedData = {
          ...data,
          'token': response['token'],
          'mustChangePassword': response['mustChangePassword'] ?? false,
        };
        print('   Merged data keys: ${mergedData.keys}');
        return AuthModel.fromJson(mergedData);
      } 
      else {
        final errorMsg = response['message'] as String? ?? 'Login failed: Invalid response format';
        print('   ❌ Login failed: $errorMsg');
        print('   Response structure: ${response.keys}');
        // Check if it's an authentication error
        final msgLower = errorMsg.toLowerCase();
        if (msgLower.contains('invalid') || 
            msgLower.contains('wrong') || 
            msgLower.contains('incorrect') ||
            msgLower.contains('email') ||
            msgLower.contains('password') ||
            msgLower.contains('credential')) {
          throw AuthenticationException(errorMsg);
        }
        throw ServerException(errorMsg);
      }
    } on NetworkException catch (e) {
      print('   ❌ AuthRemoteDataSource.login: NetworkException');
      print('   Error message: ${e.message}');
      rethrow; // Re-throw NetworkException so repository can handle it
    } on ServerException catch (e) {
      print('   ❌ AuthRemoteDataSource.login: ServerException');
      print('   Error message: ${e.message}');
      rethrow;
    } on AuthenticationException catch (e) {
      print('   ❌ AuthRemoteDataSource.login: AuthenticationException');
      print('   Error message: ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      print('   ❌ AuthRemoteDataSource.login: Unexpected error');
      print('   Error: $e');
      print('   StackTrace: $stackTrace');
      throw ServerException('Failed to login: ${e.toString()}');
    }
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword, String token) async {
    try {
      print('📤 AuthRemoteDataSource.changePassword: Sending request');
      print('   Endpoint: ${ApiConstants.counterChangePassword}');
      final response = await apiClient.post(
        ApiConstants.counterChangePassword,
        headers: {
          ApiConstants.authorizationHeader: '${ApiConstants.bearerPrefix}$token',
        },
        body: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      print('📥 AuthRemoteDataSource.changePassword: Response received');
      print('   Response: $response');

      if (response['success'] == true || response['message'] != null) {
        print('   ✅ Password changed successfully');
        return;
      } else {
        final errorMsg = response['message'] as String? ?? 'Failed to change password';
        print('   ❌ Change password failed: $errorMsg');
        throw ServerException('[AuthRemoteDataSource] $errorMsg');
      }
    } on ServerException catch (e) {
      print('   ❌ ServerException in AuthRemoteDataSource: ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      print('   ❌ Unexpected error in AuthRemoteDataSource: $e');
      print('   StackTrace: $stackTrace');
      throw ServerException('[AuthRemoteDataSource] Failed to change password: ${e.toString()}');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      print('📤 AuthRemoteDataSource.forgotPassword: Sending request');
      print('   Email: $email');
      print('   Endpoint: ${ApiConstants.counterForgotPassword}');
      final response = await apiClient.post(
        ApiConstants.counterForgotPassword,
        body: {
          'email': email,
        },
      );

      print('📥 AuthRemoteDataSource.forgotPassword: Response received');
      print('   Response: $response');

      if (response['success'] == true || response['message'] != null) {
        print('   ✅ Password reset email sent successfully');
        return;
      } else {
        final errorMsg = response['message'] as String? ?? 'Failed to send password reset email';
        print('   ❌ Forgot password failed: $errorMsg');
        throw ServerException('[AuthRemoteDataSource] $errorMsg');
      }
    } on NetworkException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e, stackTrace) {
      print('   ❌ Unexpected error in AuthRemoteDataSource.forgotPassword: $e');
      print('   StackTrace: $stackTrace');
      throw ServerException('[AuthRemoteDataSource] Failed to send password reset email: ${e.toString()}');
    }
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      print('📤 AuthRemoteDataSource.resetPassword: Sending request');
      print('   Endpoint: ${ApiConstants.counterResetPassword}');
      final response = await apiClient.post(
        ApiConstants.counterResetPassword,
        body: {
          'token': token,
          'newPassword': newPassword,
        },
      );

      print('📥 AuthRemoteDataSource.resetPassword: Response received');
      print('   Response: $response');

      if (response['success'] == true || response['message'] != null) {
        print('   ✅ Password reset successfully');
        return;
      } else {
        final errorMsg = response['message'] as String? ?? 'Failed to reset password';
        print('   ❌ Reset password failed: $errorMsg');
        throw ServerException('[AuthRemoteDataSource] $errorMsg');
      }
    } on NetworkException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e, stackTrace) {
      print('   ❌ Unexpected error in AuthRemoteDataSource.resetPassword: $e');
      print('   StackTrace: $stackTrace');
      throw ServerException('[AuthRemoteDataSource] Failed to reset password: ${e.toString()}');
    }
  }

  @override
  Future<AuthModel> signup({
    required String agencyName,
    required String ownerName,
    required String address,
    required String districtProvince,
    required String primaryContact,
    required String email,
    required String officeLocation,
    required String officeOpenTime,
    required String officeCloseTime,
    required int numberOfEmployees,
    required bool hasDeviceAccess,
    required bool hasInternetAccess,
    required String preferredBookingMethod,
    required String password,
    required File citizenshipFile,
    required File photoFile,
    String? panVatNumber,
    String? alternateContact,
    String? whatsappViber,
    File? panFile,
    File? registrationFile,
  }) async {
    try {
      // Prepare form fields
      final fields = <String, String>{
        'agencyName': agencyName,
        'ownerName': ownerName,
        'address': address,
        'districtProvince': districtProvince,
        'primaryContact': primaryContact,
        'email': email,
        'officeLocation': officeLocation,
        'officeOpenTime': officeOpenTime,
        'officeCloseTime': officeCloseTime,
        'numberOfEmployees': numberOfEmployees.toString(),
        'hasDeviceAccess': hasDeviceAccess.toString(),
        'hasInternetAccess': hasInternetAccess.toString(),
        'preferredBookingMethod': preferredBookingMethod,
        'password': password,
      };

      // Add optional fields
      if (panVatNumber != null && panVatNumber.isNotEmpty) {
        fields['panVatNumber'] = panVatNumber;
      }
      if (alternateContact != null && alternateContact.isNotEmpty) {
        fields['alternateContact'] = alternateContact;
      }
      if (whatsappViber != null && whatsappViber.isNotEmpty) {
        fields['whatsappViber'] = whatsappViber;
      }

      // Prepare files
      final files = <String, File>{
        'citizenshipFile': citizenshipFile,
        'photoFile': photoFile,
      };

      if (panFile != null) {
        files['panFile'] = panFile;
      }
      if (registrationFile != null) {
        files['registrationFile'] = registrationFile;
      }

      print('📤 AuthRemoteDataSource.signup: Sending multipart request');
      print('   Endpoint: ${ApiConstants.counterRegister}');
      print('   Fields count: ${fields.length}');
      print('   Files count: ${files.length}');
      
      final response = await multipartClient.postMultipart(
        endpoint: ApiConstants.counterRegister,
        fields: fields,
        files: files,
      );

      print('📥 AuthRemoteDataSource.signup: Response received');
      print('   Response: $response');

      // Signup returns 201 with success message, not a token
      // Account needs admin verification before login
      if (response['success'] == true || response['message'] != null) {
        print('   ✅ Signup successful, creating AuthModel');
        // Return a dummy model - actual token comes after admin verification
        return AuthModel(
          token: '', // No token until verified
          counter: CounterModel(
            id: '',
            agencyName: agencyName,
            email: email,
            phoneNumber: primaryContact,
            walletBalance: 0.0,
          ),
        );
      } else {
        final errorMsg = response['message'] as String? ?? 'Signup failed';
        print('   ❌ Signup failed: $errorMsg');
        throw ServerException('[AuthRemoteDataSource] $errorMsg');
      }
    } on NetworkException catch (e) {
      print('   ❌ NetworkException in AuthRemoteDataSource: ${e.message}');
      rethrow;
    } on TimeoutException catch (e) {
      print('   ❌ TimeoutException in AuthRemoteDataSource: ${e.message ?? "Request timeout"}');
      throw NetworkException('Request timeout: ${e.message ?? "Connection timed out"}');
    } on AuthenticationException {
      rethrow;
    } on ServerException catch (e) {
      print('   ❌ ServerException in AuthRemoteDataSource: ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      print('   ❌ Unexpected error in AuthRemoteDataSource: $e');
      print('   StackTrace: $stackTrace');
      // Check if it's a network-related error
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('network') || 
          errorStr.contains('connection') || 
          errorStr.contains('timeout') ||
          errorStr.contains('no route to host') ||
          errorStr.contains('connection refused')) {
        throw NetworkException('Network error: ${e.toString()}');
      }
      throw ServerException('[AuthRemoteDataSource] Failed to signup: ${e.toString()}');
    }
  }
}
