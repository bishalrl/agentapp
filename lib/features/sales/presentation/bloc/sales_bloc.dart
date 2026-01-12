import 'package:agentapp/features/sales/presentation/bloc/events/sales_event.dart';
import 'package:agentapp/features/sales/presentation/bloc/states/sales_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/sales_entity.dart';
import '../../domain/usecases/get_sales_summary.dart';
import '../../data/models/sales_model.dart';


class SalesBloc extends Bloc<SalesEvent, SalesState> {
  final GetSalesSummary getSalesSummary;

  SalesBloc({required this.getSalesSummary}) : super(SalesInitial()) {
    on<GetSalesSummaryEvent>(_onGetSalesSummary);
  }

  Future<void> _onGetSalesSummary(
    GetSalesSummaryEvent event,
    Emitter<SalesState> emit,
  ) async {
    emit(SalesLoading());
    final result = await getSalesSummary(
      startDate: event.startDate,
      endDate: event.endDate,
      busId: event.busId,
      paymentMethod: event.paymentMethod,
      groupBy: event.groupBy,
    );
    if (result is Error<Map<String, dynamic>>) {
      final failure = result.failure;
      String errorMessage;
      if (failure is AuthenticationFailure) {
        errorMessage = 'Authentication required. Please login again.';
      } else {
        errorMessage = failure.message;
      }
      emit(SalesError(errorMessage));
    } else if (result is Success<Map<String, dynamic>>) {
      final data = result.data;
      final summary = SalesSummaryModel.fromJson(data);
      final groupedData = (data['groupedData'] as List<dynamic>?)
              ?.map((g) => SalesGroupedDataModel.fromJson(g as Map<String, dynamic>))
              .toList() ??
          [];
      final dateRange = data['dateRange'] as Map<String, dynamic>?;
      
      emit(SalesSummaryLoaded(
        summary: summary,
        groupedData: groupedData,
        dateRange: dateRange?.map((k, v) => MapEntry(k, v.toString())),
      ));
    }
  }
}
