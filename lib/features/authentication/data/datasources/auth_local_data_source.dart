import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';

abstract class AuthLocalDataSource {
  Future<String?> getToken();
  Future<void> saveToken(String token);
  Future<void> clearToken();
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
}

