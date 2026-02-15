import '../../../../core/utils/result.dart';
import '../repositories/driver_repository.dart';

class StopLocationSharing {
  final DriverRepository repository;

  StopLocationSharing(this.repository);

  /// [busId] optional. When provided, backend can target that bus for deactivation.
  Future<Result<void>> call({String? busId}) async {
    return await repository.stopLocationSharing(busId: busId);
  }
}
