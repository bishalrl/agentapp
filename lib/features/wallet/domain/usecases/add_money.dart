import '../../../../core/utils/result.dart';
import '../entities/wallet_entity.dart';
import '../repositories/wallet_repository.dart';

class AddMoney {
  final WalletRepository repository;

  AddMoney(this.repository);

  Future<Result<WalletEntity>> call({
    required double amount,
    String? description,
  }) async {
    return await repository.addMoney(
      amount: amount,
      description: description,
    );
  }
}
