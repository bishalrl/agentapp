import '../../../../core/utils/result.dart';
import '../../domain/repositories/driver_repository.dart';

class DriverLogin {
  final DriverRepository repository;
  
  DriverLogin(this.repository);
  
  Future<Result<Map<String, dynamic>>> call({
    String? email,
    String? phoneNumber,
    required String password,
    bool? hasOTP,
    String? otp,
  }) async {
    print('🎯 DriverLogin UseCase.call: Starting');
    print('   Email: $email, PhoneNumber: $phoneNumber');
    print('   HasOTP: $hasOTP, OTP: ${otp != null ? "***" : null}');
    
    final result = await repository.login(
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      hasOTP: hasOTP,
      otp: otp,
    );
    
    if (result is Success<Map<String, dynamic>>) {
      print('   ✅ DriverLogin UseCase: Success');
    } else if (result is Error<Map<String, dynamic>>) {
      print('   ❌ DriverLogin UseCase: Error - ${result.failure.message}');
    }
    
    return result;
  }
}
