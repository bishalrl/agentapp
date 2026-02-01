import '../../../../core/utils/result.dart';
import '../entities/driver_entity.dart';
import '../repositories/driver_repository.dart';

class VerifyDriverOtp {
  final DriverRepository repository;
  
  VerifyDriverOtp(this.repository);
  
  Future<Result<Map<String, dynamic>>> call(String phoneNumber, String otp) async {
    return await repository.verifyOtp(phoneNumber, otp);
  }
}

