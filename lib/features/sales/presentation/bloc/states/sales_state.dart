import '../../../domain/entities/sales_entity.dart';

abstract class SalesState {}

class SalesInitial extends SalesState {}

class SalesLoading extends SalesState {}

class SalesSummaryLoaded extends SalesState {
  final SalesSummaryEntity summary;
  final List<SalesGroupedDataEntity> groupedData;
  final Map<String, String>? dateRange;

  SalesSummaryLoaded({
    required this.summary,
    required this.groupedData,
    this.dateRange,
  });
}

class SalesError extends SalesState {
  final String message;

  SalesError(this.message);
}
