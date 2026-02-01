import 'dart:io';
import '../../../../core/utils/result.dart';
import '../../domain/repositories/driver_repository.dart';

class RegisterDriverWithInvitation {
  final DriverRepository repository;
  
  RegisterDriverWithInvitation(this.repository);
  
  Future<Result<Map<String, dynamic>>> call({
    required String invitationCode,
    required String email,
    required String phoneNumber,
    required String password,
    required String name,
    required String licenseNumber,
    File? licensePhoto,
    File? driverPhoto,
  }) async {
    print('🎯 RegisterDriverWithInvitation UseCase.call: Starting');
    print('   InvitationCode: $invitationCode, Email: $email, Name: $name');
    print('   LicensePhoto: ${licensePhoto?.path ?? "not provided"}');
    print('   DriverPhoto: ${driverPhoto?.path ?? "not provided"}');
    
    final result = await repository.registerWithInvitation(
      invitationCode: invitationCode,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      name: name,
      licenseNumber: licenseNumber,
      licensePhoto: licensePhoto,
      driverPhoto: driverPhoto,
    );
    
    if (result is Success<Map<String, dynamic>>) {
      print('   ✅ RegisterDriverWithInvitation UseCase: Success');
    } else if (result is Error<Map<String, dynamic>>) {
      print('   ❌ RegisterDriverWithInvitation UseCase: Error - ${result.failure.message}');
    }
    
    return result;
  }
}
