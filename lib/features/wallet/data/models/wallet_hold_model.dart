import '../../domain/entities/wallet_hold_entity.dart';

class WalletHoldModel extends WalletHoldEntity {
  WalletHoldModel({
    required super.holdId,
    required super.amount,
    required super.status,
    super.description,
    super.bookingId,
    required super.createdAt,
    required super.expiresAt,
    super.confirmedAt,
    super.releasedAt,
  });

  factory WalletHoldModel.fromJson(Map<String, dynamic> json) {
    // Backend returns 'holdId' or 'id' - handle both
    final holdId = json['holdId'] as String? ?? json['id'] as String? ?? '';
    
    return WalletHoldModel(
      holdId: holdId,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      description: json['description'] as String?,
      bookingId: json['bookingId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.parse(json['confirmedAt'] as String)
          : null,
      releasedAt: json['releasedAt'] != null
          ? DateTime.parse(json['releasedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'holdId': holdId,
      'amount': amount,
      'status': status,
      'description': description,
      'bookingId': bookingId,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'confirmedAt': confirmedAt?.toIso8601String(),
      'releasedAt': releasedAt?.toIso8601String(),
    };
  }
}
