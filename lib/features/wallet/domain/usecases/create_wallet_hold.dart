import '../../../../core/utils/result.dart';
import '../entities/wallet_hold_entity.dart';
import '../repositories/wallet_hold_repository.dart';

class CreateWalletHold {
  final WalletHoldRepository repository;
  
  CreateWalletHold(this.repository);
  
  Future<Result<WalletHoldEntity>> call({
    required double amount,
    String? description,
    DateTime? expiresAt,
  }) async {
    return await repository.createHold(
      amount: amount,
      description: description,
      expiresAt: expiresAt,
    );
  }
}
