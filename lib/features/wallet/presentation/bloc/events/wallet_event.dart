abstract class WalletEvent {}

class AddMoneyEvent extends WalletEvent {
  final double amount;
  final String? description;

  AddMoneyEvent({required this.amount, this.description});
}

class GetTransactionsEvent extends WalletEvent {
  final String? type;
  final String? startDate;
  final String? endDate;
  final int? page;
  final int? limit;

  GetTransactionsEvent({
    this.type,
    this.startDate,
    this.endDate,
    this.page,
    this.limit,
  });
}
