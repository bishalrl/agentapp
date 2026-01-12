class SeatLockEntity {
  final String lockId;
  final String busId;
  final int seatNumber;
  final String lockedBy;
  final String lockedByType;
  final DateTime expiresAt;

  const SeatLockEntity({
    required this.lockId,
    required this.busId,
    required this.seatNumber,
    required this.lockedBy,
    required this.lockedByType,
    required this.expiresAt,
  });
}

