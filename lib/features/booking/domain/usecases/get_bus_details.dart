import '../../../../core/utils/result.dart';
import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

class GetBusDetails {
  final BookingRepository repository;
  
  GetBusDetails(this.repository);
  
  Future<Result<BusInfoEntity>> call(String busId) async {
    return await repository.getBusDetails(busId);
  }
}
