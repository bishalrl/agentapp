import '../../../../core/utils/result.dart';
import '../entities/bus_entity.dart';
import '../repositories/bus_repository.dart';

class CreateBus {
  final BusRepository repository;

  CreateBus(this.repository);

  Future<Result<BusEntity>> call({
    required String name,
    required String vehicleNumber,
    required String from,
    required String to,
    required DateTime date,
    required String time,
    String? arrival,
    required double price,
    required int totalSeats,
    String? busType,
    String? driverContact,
    double? commissionRate,
    List<int>? allowedSeats,
  }) async {
    print('🎯 CreateBus UseCase.call: Starting');
    print('   Name: $name, From: $from, To: $to, Date: $date');
    final result = await repository.createBus(
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
    if (result is Success<BusEntity>) {
      print('   ✅ CreateBus UseCase: Success');
    } else if (result is Error<BusEntity>) {
      print('   ❌ CreateBus UseCase: Error - ${result.failure.message}');
    }
    return result;
  }
}

