import '../../domain/entities/wallet_entity.dart';

class WalletModel extends WalletEntity {
  WalletModel({required super.balance});

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    final counter = json['counter'] ?? json;
    return WalletModel(
      balance: (counter['walletBalance'] ?? 0).toDouble(),
    );
  }
}

class WalletTransactionModel extends WalletTransactionEntity {
  WalletTransactionModel({
    required super.id,
    required super.type,
    required super.amount,
    required super.description,
    required super.createdAt,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: json['_id'] ?? json['id'] ?? '',
      type: json['type'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
