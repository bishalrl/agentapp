import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/error_message_sanitizer.dart';
import '../../../authentication/domain/usecases/get_stored_token.dart';
import '../../domain/entities/wallet_hold_entity.dart';
import '../../domain/repositories/wallet_hold_repository.dart';
import '../datasources/wallet_hold_remote_data_source.dart';

class WalletHoldRepositoryImpl implements WalletHoldRepository {
  final WalletHoldRemoteDataSource remoteDataSource;
  final GetStoredToken getStoredToken;

  WalletHoldRepositoryImpl({
    required this.remoteDataSource,
    required this.getStoredToken,
  });

  Future<String?> _getToken() async {
    final tokenResult = await getStoredToken();
    if (tokenResult is Error<String?>) {
      return null;
    } else if (tokenResult is Success<String?>) {
      return tokenResult.data;
    }
    return null;
  }

  @override
  Future<Result<WalletHoldEntity>> createHold({
    required double amount,
    String? description,
    DateTime? expiresAt,
  }) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return const Error(AuthenticationFailure('No authentication token. Please login again.'));
    }

    try {
      final hold = await remoteDataSource.createHold(
        amount: amount,
        description: description,
        expiresAt: expiresAt,
        token: token,
      );
      return Success(hold);
    } on AuthenticationException catch (e) {
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(ErrorMessageSanitizer.sanitizeRawServerMessage(e.message)));
    } catch (e) {
      return Error(ServerFailure(ErrorMessageSanitizer.getGenericErrorMessage()));
    }
  }

  @override
  Future<Result<WalletHoldEntity>> releaseHold({
    required String holdId,
  }) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return const Error(AuthenticationFailure('No authentication token. Please login again.'));
    }

    try {
      final hold = await remoteDataSource.releaseHold(
        holdId: holdId,
        token: token,
      );
      return Success(hold);
    } on AuthenticationException catch (e) {
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(ErrorMessageSanitizer.sanitizeRawServerMessage(e.message)));
    } catch (e) {
      return Error(ServerFailure(ErrorMessageSanitizer.getGenericErrorMessage()));
    }
  }

  @override
  Future<Result<WalletHoldEntity>> confirmHold({
    required String holdId,
    String? bookingId,
    String? description,
  }) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return const Error(AuthenticationFailure('No authentication token. Please login again.'));
    }

    try {
      final hold = await remoteDataSource.confirmHold(
        holdId: holdId,
        bookingId: bookingId,
        description: description,
        token: token,
      );
      return Success(hold);
    } on AuthenticationException catch (e) {
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(ErrorMessageSanitizer.sanitizeRawServerMessage(e.message)));
    } catch (e) {
      return Error(ServerFailure(ErrorMessageSanitizer.getGenericErrorMessage()));
    }
  }

  @override
  Future<Result<List<WalletHoldEntity>>> getHolds({
    String? status,
    int? limit,
    int? offset,
  }) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return const Error(AuthenticationFailure('No authentication token. Please login again.'));
    }

    try {
      final holds = await remoteDataSource.getHolds(
        status: status,
        limit: limit,
        offset: offset,
        token: token,
      );
      return Success(holds);
    } on AuthenticationException catch (e) {
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(ErrorMessageSanitizer.sanitizeRawServerMessage(e.message)));
    } catch (e) {
      return Error(ServerFailure(ErrorMessageSanitizer.getGenericErrorMessage()));
    }
  }

  @override
  Future<Result<WalletHoldEntity>> getHold({
    required String holdId,
  }) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      return const Error(AuthenticationFailure('No authentication token. Please login again.'));
    }

    try {
      final hold = await remoteDataSource.getHold(
        holdId: holdId,
        token: token,
      );
      return Success(hold);
    } on AuthenticationException catch (e) {
      return Error(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(ErrorMessageSanitizer.sanitizeRawServerMessage(e.message)));
    } catch (e) {
      return Error(ServerFailure(ErrorMessageSanitizer.getGenericErrorMessage()));
    }
  }
}
