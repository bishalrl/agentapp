import '../../../../core/utils/result.dart';
import '../entities/bus_entity.dart';

abstract class BusRepository {
  Future<Result<BusEntity>> createBus({
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
  });
  
  Future<Result<BusEntity>> updateBus({
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
  });
  
  Future<Result<void>> deleteBus(String busId);
  
  Future<Result<List<BusEntity>>> getMyBuses({
    String? date,
    String? route,
    String? status,
  });
  
  Future<Result<BusEntity>> activateBus(String busId);
  Future<Result<BusEntity>> deactivateBus(String busId);
}

