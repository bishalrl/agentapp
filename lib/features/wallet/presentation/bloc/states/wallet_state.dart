import '../../../domain/entities/wallet_entity.dart';

abstract class WalletState {}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class MoneyAdded extends WalletState {
  final WalletEntity wallet;

  MoneyAdded(this.wallet);
}

class TransactionsLoaded extends WalletState {
  final List<WalletTransactionEntity> transactions;

  TransactionsLoaded(this.transactions);
}

class WalletError extends WalletState {
  final String message;

  WalletError(this.message);
}
