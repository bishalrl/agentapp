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
    final amount = (json['amount'] as num?)?.toDouble() ?? 0.0;
    final status = json['status'] as String? ?? 'active';
    // Backend may use 'holdExpiresAt' instead of 'expiresAt'
    final expiresAtStr = json['expiresAt'] as String? ?? json['holdExpiresAt'] as String?;
    final createdAtStr = json['createdAt'] as String?;
    final createdAt = createdAtStr != null
        ? DateTime.parse(createdAtStr)
        : DateTime.now().toUtc();
    final expiresAt = expiresAtStr != null
        ? DateTime.parse(expiresAtStr)
        : createdAt.add(const Duration(hours: 1));

    return WalletHoldModel(
      holdId: holdId,
      amount: amount,
      status: status,
      description: json['description'] as String?,
      bookingId: json['bookingId'] as String?,
      createdAt: createdAt,
      expiresAt: expiresAt,
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
