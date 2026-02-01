import '../../domain/entities/counter_request_entity.dart';

class CounterRequestModel extends CounterRequestEntity {
  const CounterRequestModel({
    required super.id,
    required super.counterId,
    required super.bus,
    required super.requestedSeats,
    super.approvedSeats,
    required super.status,
    super.message,
    required super.createdAt,
    super.expiresAt,
    super.respondedAt,
  });

  factory CounterRequestModel.fromJson(Map<String, dynamic> json) {
    // Parse bus data
    final busData = json['busId'] as Map<String, dynamic>? ?? json['bus'] as Map<String, dynamic>?;
    BusRequestModel bus;
    if (busData != null) {
      bus = BusRequestModel.fromJson(busData);
    } else {
      // Fallback if bus data is missing
      bus = BusRequestModel(
        id: json['busId'] as String? ?? '',
        name: 'Unknown Bus',
        vehicleNumber: 'N/A',
        from: 'Unknown',
        to: 'Unknown',
        date: DateTime.now(),
        time: 'N/A',
        totalSeats: 0,
      );
    }

    // Parse dates
    DateTime? parseDate(String? dateStr) {
      if (dateStr == null) return null;
      try {
        return DateTime.parse(dateStr);
      } catch (e) {
        return null;
      }
    }

    // Parse requested seats
    final requestedSeatsList = json['requestedSeats'] as List<dynamic>? ?? [];
    final requestedSeats = requestedSeatsList.map((e) => e.toString()).toList();

    // Parse approved seats (if available)
    final approvedSeatsList = json['approvedSeats'] as List<dynamic>?;
    final approvedSeats = approvedSeatsList?.map((e) => (e as num).toInt()).toList();

    return CounterRequestModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      counterId: json['counterId'] as String? ?? '',
      bus: bus,
      requestedSeats: requestedSeats,
      approvedSeats: approvedSeats,
      status: json['status'] as String? ?? 'PENDING',
      message: json['message'] as String?,
      createdAt: parseDate(json['createdAt'] as String?) ?? DateTime.now(),
      expiresAt: parseDate(json['expiresAt'] as String?),
      respondedAt: parseDate(json['respondedAt'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'counterId': counterId,
      'busId': (bus as BusRequestModel).id,
      'requestedSeats': requestedSeats,
      'approvedSeats': approvedSeats,
      'status': status,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
    };
  }
}

class BusRequestModel extends BusRequestEntity {
  const BusRequestModel({
    required super.id,
    required super.name,
    required super.vehicleNumber,
    required super.from,
    required super.to,
    required super.date,
    required super.time,
    required super.totalSeats,
    super.seatConfiguration,
  });

  factory BusRequestModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(String? dateStr) {
      if (dateStr == null) return DateTime.now();
      try {
        return DateTime.parse(dateStr);
      } catch (e) {
        return DateTime.now();
      }
    }

    return BusRequestModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown Bus',
      vehicleNumber: json['vehicleNumber'] as String? ?? 'N/A',
      from: json['from'] as String? ?? 'Unknown',
      to: json['to'] as String? ?? 'Unknown',
      date: parseDate(json['date'] as String?),
      time: json['time'] as String? ?? 'N/A',
      totalSeats: (json['totalSeats'] as num?)?.toInt() ?? 0,
      seatConfiguration: (json['seatConfiguration'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'vehicleNumber': vehicleNumber,
      'from': from,
      'to': to,
      'date': date.toIso8601String(),
      'time': time,
      'totalSeats': totalSeats,
      'seatConfiguration': seatConfiguration,
    };
  }
}
