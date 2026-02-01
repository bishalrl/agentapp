import '../../../../core/utils/result.dart';
import '../entities/counter_request_entity.dart';

abstract class CounterRequestRepository {
  /// Request access to a bus with specific seat numbers
  /// Returns the created request entity
  Future<Result<CounterRequestEntity>> requestBusAccess({
    required String busId,
    required List<String> requestedSeats,
    String? message,
  });

  /// Get all requests made by the counter
  /// Returns list of request entities
  Future<Result<List<CounterRequestEntity>>> getCounterRequests();
}
