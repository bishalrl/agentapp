import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/error_message_sanitizer.dart';
import '../../domain/entities/seat_lock_entity.dart';
import '../../domain/repositories/seat_lock_repository.dart';
import '../datasources/seat_lock_remote_data_source.dart';

class SeatLockRepositoryImpl implements SeatLockRepository {
  final SeatLockRemoteDataSource remoteDataSource;
  final String? token;

  SeatLockRepositoryImpl(this.remoteDataSource, {this.token});

  @override
  Future<Result<SeatLockEntity>> lockSeat(String busId, int seatNumber) async {
    if (token == null) {
      return const Error(AuthenticationFailure('No authentication token'));
    }

    try {
      final lock = await remoteDataSource.lockSeat(busId, seatNumber, token!);
      return Success(lock);
    } on AuthenticationException catch (e) {
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(ErrorMessageSanitizer.sanitizeRawServerMessage(e.message)));
    } catch (e) {
      return Error(ServerFailure(ErrorMessageSanitizer.getGenericErrorMessage()));
    }
  }

  @override
  Future<Result<List<SeatLockEntity>>> lockMultipleSeats(String busId, List<int> seatNumbers) async {
    if (token == null) {
      return const Error(AuthenticationFailure('No authentication token'));
    }

    try {
      final locks = await remoteDataSource.lockMultipleSeats(busId, seatNumbers, token!);
      return Success(locks);
    } on AuthenticationException catch (e) {
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(ErrorMessageSanitizer.sanitizeRawServerMessage(e.message)));
    } catch (e) {
      return Error(ServerFailure(ErrorMessageSanitizer.getGenericErrorMessage()));
    }
  }

  @override
  Future<Result<void>> unlockSeat(String busId, int seatNumber) async {
    if (token == null) {
      return const Error(AuthenticationFailure('No authentication token'));
    }

    try {
      await remoteDataSource.unlockSeat(busId, seatNumber, token!);
      return const Success(null);
    } on AuthenticationException catch (e) {
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(ErrorMessageSanitizer.sanitizeRawServerMessage(e.message)));
    } catch (e) {
      return Error(ServerFailure(ErrorMessageSanitizer.getGenericErrorMessage()));
    }
  }

  @override
  Future<Result<List<SeatLockEntity>>> getBusLocks(String busId) async {
    if (token == null) {
      return const Error(AuthenticationFailure('No authentication token'));
    }

    try {
      final locks = await remoteDataSource.getBusLocks(busId, token!);
      return Success(locks);
    } on AuthenticationException catch (e) {
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(ErrorMessageSanitizer.sanitizeRawServerMessage(e.message)));
    } catch (e) {
      return Error(ServerFailure(ErrorMessageSanitizer.getGenericErrorMessage()));
    }
  }

  @override
  Future<Result<List<SeatLockEntity>>> getMyLocks() async {
    if (token == null) {
      return const Error(AuthenticationFailure('No authentication token'));
    }

    try {
      final locks = await remoteDataSource.getMyLocks(token!);
      return Success(locks);
    } on AuthenticationException catch (e) {
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(ErrorMessageSanitizer.sanitizeRawServerMessage(e.message)));
    } catch (e) {
      return Error(ServerFailure(ErrorMessageSanitizer.getGenericErrorMessage()));
    }
  }
}

