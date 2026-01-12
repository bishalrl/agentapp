import '../../../../core/utils/result.dart';
import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

class GetAvailableBuses {
  final BookingRepository repository;
  
  GetAvailableBuses(this.repository);
  
  Future<Result<List<BusInfoEntity>>> call({
    String? date,
    String? route,
    String? status,
  }) async {
    return await repository.getAvailableBuses(
      date: date,
      route: route,
      status: status,
    );
  }
}

