import 'dart:io';
import '../../../../core/utils/result.dart';
import '../repositories/driver_repository.dart';

class RegisterDriver {
  final DriverRepository repository;

  RegisterDriver(this.repository);

  Future<Result<Map<String, dynamic>>> call({
    required String name,
    required String phoneNumber,
    String? email,
    required String password,
    required String licenseNumber,
    File? licensePhoto,
    File? driverPhoto,
    bool? hasOTP,
    String? otp,
  }) async {
    print('🎯 RegisterDriver UseCase.call: Starting (Independent Registration)');
    print('   Name: $name, PhoneNumber: $phoneNumber, Email: $email');
    print('   LicenseNumber: $licenseNumber');
    print('   HasOTP: $hasOTP, OTP: ${otp != null ? "***" : null}');
    
    final result = await repository.register(
      name: name,
      phoneNumber: phoneNumber,
      email: email,
      password: password,
      licenseNumber: licenseNumber,
      licensePhoto: licensePhoto,
      driverPhoto: driverPhoto,
      hasOTP: hasOTP,
      otp: otp,
    );
    
    if (result is Success<Map<String, dynamic>>) {
      print('   ✅ RegisterDriver UseCase: Success');
    } else if (result is Error<Map<String, dynamic>>) {
      print('   ❌ RegisterDriver UseCase: Error - ${result.failure.message}');
    }
    
    return result;
  }
}
