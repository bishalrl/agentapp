import '../../../../core/utils/result.dart';
import '../entities/wallet_hold_entity.dart';
import '../repositories/wallet_hold_repository.dart';

class ReleaseWalletHold {
  final WalletHoldRepository repository;
  
  ReleaseWalletHold(this.repository);
  
  Future<Result<WalletHoldEntity>> call({
    required String holdId,
  }) async {
    return await repository.releaseHold(holdId: holdId);
  }
}
