import '../../../../core/utils/result.dart';
import '../entities/wallet_entity.dart';
import '../repositories/wallet_repository.dart';

class GetTransactions {
  final WalletRepository repository;

  GetTransactions(this.repository);

  Future<Result<List<WalletTransactionEntity>>> call({
    String? type,
    String? startDate,
    String? endDate,
    int? page,
    int? limit,
  }) async {
    return await repository.getTransactions(
      type: type,
      startDate: startDate,
      endDate: endDate,
      page: page,
      limit: limit,
    );
  }
}
