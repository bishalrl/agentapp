import '../../../../core/utils/result.dart';
import '../entities/wallet_hold_entity.dart';
import '../repositories/wallet_hold_repository.dart';

class ConfirmWalletHold {
  final WalletHoldRepository repository;
  
  ConfirmWalletHold(this.repository);
  
  Future<Result<WalletHoldEntity>> call({
    required String holdId,
    String? bookingId,
    String? description,
  }) async {
    return await repository.confirmHold(
      holdId: holdId,
      bookingId: bookingId,
      description: description,
    );
  }
}
