import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/error_message_sanitizer.dart';
import '../../../../core/session/session_manager.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';
import '../../../../features/authentication/domain/usecases/get_stored_token.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  final GetStoredToken getStoredToken;

  NotificationRepositoryImpl({
    required this.remoteDataSource,
    required this.getStoredToken,
  });

  @override
  Future<Result<List<NotificationEntity>>> getNotifications({
    bool? read,
    String? type,
    int? page,
    int? limit,
  }) async {
    final tokenResult = await getStoredToken();
    String? token;
    if (tokenResult is Error<String?>) {
      return Error(AuthenticationFailure('Authentication required. Please login again.'));
    } else if (tokenResult is Success<String?>) {
      token = tokenResult.data;
    }

    if (token == null || token.isEmpty) {
      return const Error(AuthenticationFailure('No authentication token. Please login again.'));
    }

    try {
      final notifications = await remoteDataSource.getNotifications(
        read: read,
        type: type,
        page: page,
        limit: limit,
        token: token,
      );
      return Success(notifications);
    } on AuthenticationException catch (e) {
      if (!SessionManager().isLoggingOut) {
        SessionManager().handleAuthenticationError();
      }
      return Error(AuthenticationFailure('Session expired. Please login again.'));
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(ErrorMessageSanitizer.sanitizeRawServerMessage(e.message)));
    } catch (e) {
      return Error(ServerFailure(ErrorMessageSanitizer.getGenericErrorMessage()));
    }
  }

  @override
  Future<Result<int>> markAsRead({required List<String> notificationIds}) async {
    final tokenResult = await getStoredToken();
    String? token;
    if (tokenResult is Error<String?>) {
      return Error(AuthenticationFailure('Authentication required. Please login again.'));
    } else if (tokenResult is Success<String?>) {
      token = tokenResult.data;
    }

    if (token == null || token.isEmpty) {
      return const Error(AuthenticationFailure('No authentication token. Please login again.'));
    }

    try {
      final count = await remoteDataSource.markAsRead(
        notificationIds: notificationIds,
        token: token,
      );
      return Success(count);
    } on AuthenticationException catch (e) {
      if (!SessionManager().isLoggingOut) {
        SessionManager().handleAuthenticationError();
      }
      return Error(AuthenticationFailure('Session expired. Please login again.'));
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(ErrorMessageSanitizer.sanitizeRawServerMessage(e.message)));
    } catch (e) {
      return Error(ServerFailure(ErrorMessageSanitizer.getGenericErrorMessage()));
    }
  }

  @override
  Future<Result<int>> markAllAsRead() async {
    final tokenResult = await getStoredToken();
    String? token;
    if (tokenResult is Error<String?>) {
      return Error(AuthenticationFailure('Authentication required. Please login again.'));
    } else if (tokenResult is Success<String?>) {
      token = tokenResult.data;
    }

    if (token == null || token.isEmpty) {
      return const Error(AuthenticationFailure('No authentication token. Please login again.'));
    }

    try {
      final count = await remoteDataSource.markAllAsRead(token: token);
      return Success(count);
    } on AuthenticationException catch (e) {
      if (!SessionManager().isLoggingOut) {
        SessionManager().handleAuthenticationError();
      }
      return Error(AuthenticationFailure('Session expired. Please login again.'));
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(ErrorMessageSanitizer.sanitizeRawServerMessage(e.message)));
    } catch (e) {
      return Error(ServerFailure(ErrorMessageSanitizer.getGenericErrorMessage()));
    }
  }

  @override
  Future<Result<void>> deleteNotification(String notificationId) async {
    final tokenResult = await getStoredToken();
    String? token;
    if (tokenResult is Error<String?>) {
      return Error(AuthenticationFailure('Authentication required. Please login again.'));
    } else if (tokenResult is Success<String?>) {
      token = tokenResult.data;
    }

    if (token == null || token.isEmpty) {
      return const Error(AuthenticationFailure('No authentication token. Please login again.'));
    }

    try {
      await remoteDataSource.deleteNotification(notificationId, token);
      return const Success(null);
    } on AuthenticationException catch (e) {
      if (!SessionManager().isLoggingOut) {
        SessionManager().handleAuthenticationError();
      }
      return Error(AuthenticationFailure('Session expired. Please login again.'));
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(ErrorMessageSanitizer.sanitizeRawServerMessage(e.message)));
    } catch (e) {
      return Error(ServerFailure(ErrorMessageSanitizer.getGenericErrorMessage()));
    }
  }

  @override
  Future<Result<int>> deleteAllNotifications() async {
    final tokenResult = await getStoredToken();
    String? token;
    if (tokenResult is Error<String?>) {
      return Error(AuthenticationFailure('Authentication required. Please login again.'));
    } else if (tokenResult is Success<String?>) {
      token = tokenResult.data;
    }

    if (token == null || token.isEmpty) {
      return const Error(AuthenticationFailure('No authentication token. Please login again.'));
    }

    try {
      final count = await remoteDataSource.deleteAllNotifications(token);
      return Success(count);
    } on AuthenticationException catch (e) {
      if (!SessionManager().isLoggingOut) {
        SessionManager().handleAuthenticationError();
      }
      return Error(AuthenticationFailure('Session expired. Please login again.'));
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(ErrorMessageSanitizer.sanitizeRawServerMessage(e.message)));
    } catch (e) {
      return Error(ServerFailure(ErrorMessageSanitizer.getGenericErrorMessage()));
    }
  }
}
