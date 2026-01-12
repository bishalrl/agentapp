import '../../../../core/utils/result.dart';
import '../entities/bus_entity.dart';
import '../repositories/bus_repository.dart';

class UpdateBus {
  final BusRepository repository;

  UpdateBus(this.repository);

  Future<Result<BusEntity>> call({
    required String busId,
    String? name,
    String? vehicleNumber,
    String? from,
    String? to,
    DateTime? date,
    String? time,
    String? arrival,
    double? price,
    int? totalSeats,
    String? busType,
    String? driverContact,
    double? commissionRate,
    List<int>? allowedSeats,
  }) async {
    return await repository.updateBus(
      busId: busId,
      name: name,
      vehicleNumber: vehicleNumber,
      from: from,
      to: to,
      date: date,
      time: time,
      arrival: arrival,
      price: price,
      totalSeats: totalSeats,
      busType: busType,
      driverContact: driverContact,
      commissionRate: commissionRate,
      allowedSeats: allowedSeats,
    );
  }
}

