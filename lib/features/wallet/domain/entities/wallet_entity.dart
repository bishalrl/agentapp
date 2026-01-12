class WalletEntity {
  final double balance;

  WalletEntity({required this.balance});
}

class WalletTransactionEntity {
  final String id;
  final String type; // 'credit' or 'debit'
  final double amount;
  final String description;
  final DateTime createdAt;

  WalletTransactionEntity({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.createdAt,
  });
}
