import '../../../../core/utils/result.dart';
import '../entities/auth_entity.dart';
import 'dart:io';

abstract class AuthRepository {
  Future<Result<AuthEntity>> login(String email, String password, {String loginType = 'counter'});
  Future<Result<AuthEntity>> signup({
    required String type,
    required String agencyName,
    required String ownerName,
    String? name,
    required String address,
    required String districtProvince,
    required String primaryContact,
    required String email,
    String? officeLocation,
    String? officeOpenTime,
    String? officeCloseTime,
    int? numberOfEmployees,
    bool? hasDeviceAccess,
    bool? hasInternetAccess,
    String? preferredBookingMethod,
    required String password,
    required File citizenshipFile,
    required File photoFile,
    File? nameMatchImage,
    String? panVatNumber,
    String? alternateContact,
    String? whatsappViber,
    File? panFile,
    File? registrationFile,
  });
  Future<Result<void>> changePassword(String currentPassword, String newPassword, String token);
  Future<Result<void>> forgotPassword(String email);
  Future<Result<void>> resetPassword(String token, String newPassword);
  Future<Result<void>> logout();
  Future<Result<String?>> getStoredToken();
  Future<Result<void>> saveToken(String token);
  Future<Result<void>> clearToken();
  Future<Result<String?>> getStoredSessionType();
  Future<Result<void>> saveSessionType(String type);
  Future<Result<void>> clearSessionType();
}

