import '../../domain/entities/seat_lock_entity.dart';

class SeatLockModel extends SeatLockEntity {
  const SeatLockModel({
    required super.lockId,
    required super.busId,
    required super.seatNumber,
    required super.lockedBy,
    required super.lockedByType,
    required super.expiresAt,
  });

  factory SeatLockModel.fromJson(Map<String, dynamic> json) {
    return SeatLockModel(
      lockId: json['lockId'] as String? ?? json['_id'] as String,
      busId: json['busId'] as String,
      seatNumber: json['seatNumber'] as int,
      lockedBy: json['lockedBy'] as String,
      lockedByType: json['lockedByType'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }
}

