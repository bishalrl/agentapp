import '../../../../core/utils/result.dart';
import '../entities/wallet_hold_entity.dart';

abstract class WalletHoldRepository {
  Future<Result<WalletHoldEntity>> createHold({
    required double amount,
    String? description,
    DateTime? expiresAt,
  });
  
  Future<Result<WalletHoldEntity>> releaseHold({
    required String holdId,
  });
  
  Future<Result<WalletHoldEntity>> confirmHold({
    required String holdId,
    String? bookingId,
    String? description,
  });
  
  Future<Result<List<WalletHoldEntity>>> getHolds({
    String? status,
    int? limit,
    int? offset,
  });
  
  Future<Result<WalletHoldEntity>> getHold({
    required String holdId,
  });
}
