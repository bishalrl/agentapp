import 'dart:io';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/network_info.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/auth_local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Result<AuthEntity>> signup({
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
      if (await networkInfo.isConnected) {
        try {
          print('📦 AuthRepositoryImpl.signup: Calling remoteDataSource');
          // Signup returns model with empty token - account needs admin verification
          final auth = await remoteDataSource.signup(
            agencyName: agencyName,
            ownerName: ownerName,
            address: address,
            districtProvince: districtProvince,
            primaryContact: primaryContact,
            email: email,
            officeLocation: officeLocation,
            officeOpenTime: officeOpenTime,
            officeCloseTime: officeCloseTime,
            numberOfEmployees: numberOfEmployees,
            hasDeviceAccess: hasDeviceAccess,
            hasInternetAccess: hasInternetAccess,
            preferredBookingMethod: preferredBookingMethod,
            password: password,
            citizenshipFile: citizenshipFile,
            photoFile: photoFile,
            panVatNumber: panVatNumber,
            alternateContact: alternateContact,
            whatsappViber: whatsappViber,
            panFile: panFile,
            registrationFile: registrationFile,
          );
          
          print('   ✅ AuthRepositoryImpl.signup: Success, returning Success result');
          // Don't save token (it's empty) - user needs to wait for verification
          return Success(auth);
        } on NetworkException catch (e) {
          print('   ❌ AuthRepositoryImpl.signup: NetworkException');
          print('   Error: ${e.message}');
          return Error(NetworkFailure(e.message));
        } on AuthenticationException catch (e) {
          print('   ❌ AuthRepositoryImpl.signup: AuthenticationException');
          print('   Error: ${e.message}');
          return Error(AuthenticationFailure(e.message));
        } on ServerException catch (e) {
          print('   ❌ AuthRepositoryImpl.signup: ServerException caught');
          print('   Error message: ${e.message}');
          final failure = ServerFailure(e.message.isEmpty ? 'Unknown server error' : e.message);
          print('   Returning Error with message: ${failure.message}');
          return Error(failure);
        }
      } else {
        return const Error(NetworkFailure('No internet connection'));
      }
    } catch (e) {
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Result<AuthEntity>> login(String email, String password) async {
    try {
      print('📦 AuthRepositoryImpl.login: Starting login process');
      print('   Email: $email');
      if (await networkInfo.isConnected) {
        print('   ✅ Network connected, calling remoteDataSource');
        try {
          final auth = await remoteDataSource.login(email, password);
          print('   ✅ AuthRepositoryImpl.login: Remote login successful');
          print('   Token length: ${auth.token.length}');
          await localDataSource.saveToken(auth.token);
          print('   ✅ Token saved to local storage');
          return Success(auth);
        } on NetworkException catch (e) {
          print('   ❌ AuthRepositoryImpl.login: NetworkException');
          print('   Error: ${e.message}');
          return Error(NetworkFailure(e.message));
        } on AuthenticationException catch (e) {
          print('   ❌ AuthRepositoryImpl.login: AuthenticationException');
          print('   Error: ${e.message}');
          return Error(AuthenticationFailure(e.message));
        } on ServerException catch (e) {
          print('   ❌ AuthRepositoryImpl.login: ServerException');
          print('   Error: ${e.message}');
          return Error(ServerFailure(e.message));
        }
      } else {
        print('   ❌ AuthRepositoryImpl.login: No network connection');
        return const Error(NetworkFailure('No internet connection'));
      }
    } catch (e, stackTrace) {
      print('   ❌ AuthRepositoryImpl.login: Unexpected error');
      print('   Error: $e');
      print('   StackTrace: $stackTrace');
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void>> changePassword(String currentPassword, String newPassword, String token) async {
    try {
      if (await networkInfo.isConnected) {
        try {
          print('📦 AuthRepositoryImpl.changePassword: Calling remoteDataSource');
          await remoteDataSource.changePassword(currentPassword, newPassword, token);
          print('   ✅ AuthRepositoryImpl.changePassword: Success');
          return const Success(null);
        } on ServerException catch (e) {
          print('   ❌ AuthRepositoryImpl.changePassword: ServerException caught');
          print('   Error message: ${e.message}');
          return Error(ServerFailure(e.message.isEmpty ? 'Failed to change password' : e.message));
        }
      } else {
        return const Error(NetworkFailure('No internet connection'));
      }
    } catch (e) {
      print('   ❌ AuthRepositoryImpl.changePassword: Unexpected error: $e');
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void>> forgotPassword(String email) async {
    try {
      if (await networkInfo.isConnected) {
        try {
          print('📦 AuthRepositoryImpl.forgotPassword: Calling remoteDataSource');
          await remoteDataSource.forgotPassword(email);
          print('   ✅ AuthRepositoryImpl.forgotPassword: Success');
          return const Success(null);
        } on NetworkException catch (e) {
          print('   ❌ AuthRepositoryImpl.forgotPassword: NetworkException');
          print('   Error: ${e.message}');
          return Error(NetworkFailure(e.message));
        } on ServerException catch (e) {
          print('   ❌ AuthRepositoryImpl.forgotPassword: ServerException');
          print('   Error: ${e.message}');
          return Error(ServerFailure(e.message));
        }
      } else {
        return const Error(NetworkFailure('No internet connection'));
      }
    } catch (e) {
      print('   ❌ AuthRepositoryImpl.forgotPassword: Unexpected error: $e');
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void>> resetPassword(String token, String newPassword) async {
    try {
      if (await networkInfo.isConnected) {
        try {
          print('📦 AuthRepositoryImpl.resetPassword: Calling remoteDataSource');
          await remoteDataSource.resetPassword(token, newPassword);
          print('   ✅ AuthRepositoryImpl.resetPassword: Success');
          return const Success(null);
        } on NetworkException catch (e) {
          print('   ❌ AuthRepositoryImpl.resetPassword: NetworkException');
          print('   Error: ${e.message}');
          return Error(NetworkFailure(e.message));
        } on ServerException catch (e) {
          print('   ❌ AuthRepositoryImpl.resetPassword: ServerException');
          print('   Error: ${e.message}');
          return Error(ServerFailure(e.message));
        }
      } else {
        return const Error(NetworkFailure('No internet connection'));
      }
    } catch (e) {
      print('   ❌ AuthRepositoryImpl.resetPassword: Unexpected error: $e');
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await localDataSource.clearToken();
      return const Success(null);
    } on CacheException catch (e) {
      return Error(CacheFailure(e.message));
    } catch (e) {
      return Error(CacheFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Result<String?>> getStoredToken() async {
    try {
      final token = await localDataSource.getToken();
      return Success(token);
    } on CacheException catch (e) {
      return Error(CacheFailure(e.message));
    } catch (e) {
      return Error(CacheFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void>> saveToken(String token) async {
    try {
      await localDataSource.saveToken(token);
      return const Success(null);
    } on CacheException catch (e) {
      return Error(CacheFailure(e.message));
    } catch (e) {
      return Error(CacheFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void>> clearToken() async {
    try {
      await localDataSource.clearToken();
      return const Success(null);
    } on CacheException catch (e) {
      return Error(CacheFailure(e.message));
    } catch (e) {
      return Error(CacheFailure('Unexpected error: ${e.toString()}'));
    }
  }
}

