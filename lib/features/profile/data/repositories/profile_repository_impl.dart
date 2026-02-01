import 'dart:io';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/session/session_manager.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../datasources/profile_local_data_source.dart';
import '../../../../features/authentication/domain/usecases/get_stored_token.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;
  final GetStoredToken getStoredToken;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.getStoredToken,
  });

  @override
  Future<Result<ProfileEntity>> getProfile() async {
    // Try to get cached profile first
    ProfileEntity? cachedProfile;
    try {
      cachedProfile = await localDataSource.getCachedProfile();
    } catch (e) {
      // Cache error is not critical
    }

    final tokenResult = await getStoredToken();
    String? token;
    if (tokenResult is Error<String?>) {
      if (cachedProfile != null) {
        return Success(cachedProfile);
      }
      return Error(AuthenticationFailure('Authentication required. Please login again.'));
    } else if (tokenResult is Success<String?>) {
      token = tokenResult.data;
    }

    if (token == null || token.isEmpty) {
      if (cachedProfile != null) {
        return Success(cachedProfile);
      }
      return const Error(AuthenticationFailure('No authentication token. Please login again.'));
    }

    try {
      final profile = await remoteDataSource.getProfile(token);
      
      // Cache the profile
      try {
        await localDataSource.cacheProfile(profile);
      } catch (e) {
        // Cache error is not critical
      }
      
      return Success(profile);
    } on AuthenticationException catch (e) {
      if (cachedProfile != null) {
        return Success(cachedProfile);
      }
      if (!SessionManager().isLoggingOut) {
        SessionManager().handleAuthenticationError();
      }
      return Error(AuthenticationFailure('Session expired. Please login again.'));
    } on NetworkException catch (e) {
      if (cachedProfile != null) {
        return Success(cachedProfile);
      }
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      if (cachedProfile != null) {
        return Success(cachedProfile);
      }
      return Error(ServerFailure(e.message));
    } catch (e) {
      if (cachedProfile != null) {
        return Success(cachedProfile);
      }
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Result<ProfileEntity>> updateProfile({
    String? agencyName,
    String? ownerName,
    String? panVatNumber,
    String? address,
    String? districtProvince,
    String? primaryContact,
    String? alternateContact,
    String? whatsappViber,
    String? officeLocation,
    String? officeOpenTime,
    String? officeCloseTime,
    int? numberOfEmployees,
    bool? hasDeviceAccess,
    bool? hasInternetAccess,
    String? preferredBookingMethod,
    String? avatarPath,
  }) async {
    final tokenResult = await getStoredToken();
    String? token;
    if (tokenResult is Error<String?>) {
      return Error(AuthenticationFailure('Authentication required. Please login again.'));
    } else if (tokenResult is Success<String?>) {
      token = tokenResult.data;
    }

    if (token == null || token.isEmpty) {
      return const Error(AuthenticationFailure('No authentication token. Please login again.'));
    }

    try {
      File? avatar;
      if (avatarPath != null && avatarPath.isNotEmpty) {
        avatar = File(avatarPath);
      }

      final profile = await remoteDataSource.updateProfile(
        token: token,
        agencyName: agencyName,
        ownerName: ownerName,
        panVatNumber: panVatNumber,
        address: address,
        districtProvince: districtProvince,
        primaryContact: primaryContact,
        alternateContact: alternateContact,
        whatsappViber: whatsappViber,
        officeLocation: officeLocation,
        officeOpenTime: officeOpenTime,
        officeCloseTime: officeCloseTime,
        numberOfEmployees: numberOfEmployees,
        hasDeviceAccess: hasDeviceAccess,
        hasInternetAccess: hasInternetAccess,
        preferredBookingMethod: preferredBookingMethod,
        avatar: avatar,
      );
      return Success(profile);
    } on AuthenticationException catch (e) {
      if (!SessionManager().isLoggingOut) {
        SessionManager().handleAuthenticationError();
      }
      return Error(AuthenticationFailure('Session expired. Please login again.'));
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
