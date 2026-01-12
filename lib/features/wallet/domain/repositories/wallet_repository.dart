import '../../../../core/utils/result.dart';
import '../entities/wallet_entity.dart';

abstract class WalletRepository {
  Future<Result<WalletEntity>> addMoney({
    required double amount,
    String? description,
  });
  Future<Result<List<WalletTransactionEntity>>> getTransactions({
    String? type,
    String? startDate,
    String? endDate,
    int? page,
    int? limit,
  });
}
