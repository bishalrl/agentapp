import 'package:agentapp/features/audit_logs/presentation/bloc/events/audit_log_event.dart';
import 'package:agentapp/features/audit_logs/presentation/bloc/states/audit_log_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/audit_log_entity.dart';
import '../../domain/usecases/get_audit_logs.dart';


class AuditLogBloc extends Bloc<AuditLogEvent, AuditLogState> {
  final GetAuditLogs getAuditLogs;

  AuditLogBloc({required this.getAuditLogs}) : super(AuditLogInitial()) {
    on<GetAuditLogsEvent>(_onGetAuditLogs);
  }

  Future<void> _onGetAuditLogs(
    GetAuditLogsEvent event,
    Emitter<AuditLogState> emit,
  ) async {
    emit(AuditLogLoading());
    final result = await getAuditLogs(
      action: event.action,
      startDate: event.startDate,
      endDate: event.endDate,
      page: event.page,
      limit: event.limit,
    );
    if (result is Error<List<AuditLogEntity>>) {
      final failure = result.failure;
      String errorMessage;
      if (failure is AuthenticationFailure) {
        errorMessage = 'Authentication required. Please login again.';
      } else {
        errorMessage = failure.message;
      }
      emit(AuditLogError(errorMessage));
    } else if (result is Success<List<AuditLogEntity>>) {
      emit(AuditLogsLoaded(result.data));
    }
  }
}
