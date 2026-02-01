import '../../../../core/utils/result.dart';
import '../../domain/repositories/driver_repository.dart';

class VerifyTicket {
  final DriverRepository repository;
  
  VerifyTicket(this.repository);
  
  Future<Result<Map<String, dynamic>>> call({
    required String qrCode,
    required String busId,
    int? seatNumber,
  }) async {
    return await repository.verifyTicket(
      qrCode: qrCode,
      busId: busId,
      seatNumber: seatNumber,
    );
  }
}
