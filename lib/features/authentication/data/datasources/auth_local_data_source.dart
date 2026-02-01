import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';

abstract class AuthLocalDataSource {
  Future<String?> getToken();
  Future<void> saveToken(String token);
  Future<void> clearToken();
  Future<String?> getSessionType();
  Future<void> saveSessionType(String type);
  Future<void> clearSessionType();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl(this.secureStorage);

  @override
  Future<String?> getToken() async {
    try {
      return await secureStorage.read(key: AppConstants.tokenKey);
    } catch (e) {
      throw CacheException('Failed to get token: ${e.toString()}');
    }
  }

  @override
  Future<void> saveToken(String token) async {
    try {
      await secureStorage.write(key: AppConstants.tokenKey, value: token);
    } catch (e) {
      throw CacheException('Failed to save token: ${e.toString()}');
    }
  }

  @override
  Future<void> clearToken() async {
    try {
      await secureStorage.delete(key: AppConstants.tokenKey);
    } catch (e) {
      throw CacheException('Failed to clear token: ${e.toString()}');
    }
  }

  @override
  Future<String?> getSessionType() async {
    try {
      return await secureStorage.read(key: AppConstants.sessionTypeKey);
    } catch (e) {
      throw CacheException('Failed to get session type: ${e.toString()}');
    }
  }

  @override
  Future<void> saveSessionType(String type) async {
    try {
      await secureStorage.write(key: AppConstants.sessionTypeKey, value: type);
    } catch (e) {
      throw CacheException('Failed to save session type: ${e.toString()}');
    }
  }

  @override
  Future<void> clearSessionType() async {
    try {
      await secureStorage.delete(key: AppConstants.sessionTypeKey);
    } catch (e) {
      throw CacheException('Failed to clear session type: ${e.toString()}');
    }
  }
}

