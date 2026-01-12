abstract class SalesEvent {}

class GetSalesSummaryEvent extends SalesEvent {
  final String? startDate;
  final String? endDate;
  final String? busId;
  final String? paymentMethod;
  final String? groupBy;

  GetSalesSummaryEvent({
    this.startDate,
    this.endDate,
    this.busId,
    this.paymentMethod,
    this.groupBy,
  });
}
