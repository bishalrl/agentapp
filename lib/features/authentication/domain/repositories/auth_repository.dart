import '../../../../core/utils/result.dart';
import '../entities/auth_entity.dart';
import 'dart:io';

abstract class AuthRepository {
  Future<Result<AuthEntity>> login(String email, String password);
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
  });
  Future<Result<void>> changePassword(String currentPassword, String newPassword, String token);
  Future<Result<void>> forgotPassword(String email);
  Future<Result<void>> resetPassword(String token, String newPassword);
  Future<Result<void>> logout();
  Future<Result<String?>> getStoredToken();
  Future<Result<void>> saveToken(String token);
  Future<Result<void>> clearToken();
}

