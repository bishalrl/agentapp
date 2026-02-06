class WalletHoldEntity {
  final String holdId;
  final double amount;
  final String status; // 'active', 'confirmed', 'released', 'expired'
  final String? description;
  final String? bookingId;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? confirmedAt;
  final DateTime? releasedAt;

  WalletHoldEntity({
    required this.holdId,
    required this.amount,
    required this.status,
    this.description,
    this.bookingId,
    required this.createdAt,
    required this.expiresAt,
    this.confirmedAt,
    this.releasedAt,
  });
}
