import 'dart:convert';
import '../../domain/entities/bus_entity.dart';

class BusModel extends BusEntity {
  const BusModel({
    required super.id,
    required super.name,
    required super.vehicleNumber,
    required super.from,
    required super.to,
    required super.date,
    required super.time,
    super.arrival,
    super.timeFormat,
    super.arrivalFormat,
    super.tripDirection,
    super.tripStatus,
    super.reachedAt,
    required super.price,
    required super.totalSeats,
    super.busType,
    super.driverContact,
    super.driverId,
    super.driverEmail,
    super.driverName,
    super.commissionRate,
    super.ownerId,
    super.ownerEmail,
    super.accessId,
    super.allowedSeats,
    super.seatConfiguration,
    super.amenities,
    super.boardingPoints,
    super.droppingPoints,
    super.routeId,
    super.scheduleId,
    super.parentBusId,
    super.recurringScheduleId,
    super.distance,
    super.estimatedDuration,
    super.mainImageUrl,
    super.galleryImages,
    super.isActive,
    super.isRecurring,
    super.recurringDays,
    super.recurringStartDate,
    super.recurringEndDate,
    super.recurringFrequency,
    super.autoActivate,
    super.activeFromDate,
    super.activeToDate,
  });

  factory BusModel.fromJson(Map<String, dynamic> json) {
    print('🔍 BusModel.fromJson: Parsing JSON');
    print('   JSON keys: ${json.keys}');
    
    // Parse amenities - can be array or comma-separated string
    List<String>? parseAmenities(dynamic value) {
      if (value == null) return null;
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      if (value is String) {
        return value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
      return null;
    }
    
    // Parse boarding/dropping points - can be array or JSON string
    List<Map<String, String>>? parsePoints(dynamic value) {
      if (value == null) return null;
      if (value is List) {
        return value.map((e) {
          if (e is Map<String, dynamic>) {
            return e.map((k, v) => MapEntry(k, v.toString()));
          }
          return <String, String>{};
        }).toList();
      }
      if (value is String) {
        try {
          final decoded = jsonDecode(value) as List<dynamic>;
          return decoded.map((e) {
            if (e is Map<String, dynamic>) {
              return e.map((k, v) => MapEntry(k, v.toString()));
            }
            return <String, String>{};
          }).toList();
        } catch (e) {
          print('   ⚠️ Failed to parse points JSON string: $e');
          return null;
        }
      }
      return null;
    }
    
    // Parse driverId - can be string or object with _id
    String? parseDriverId(dynamic value) {
      if (value == null) return null;
      if (value is String) return value;
      if (value is Map<String, dynamic>) {
        return value['_id'] as String? ?? value['id'] as String?;
      }
      return null;
    }
    
    // Parse recurring days
    List<int>? parseRecurringDays(dynamic value) {
      if (value == null) return null;
      if (value is List) {
        return value.map((e) => e as int).toList();
      }
      return null;
    }
    
    // Parse date strings to DateTime
    DateTime? parseDateString(dynamic value) {
      if (value == null) return null;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return null;
        }
      }
      return null;
    }
    
    // Route fallback: some APIs may send nested route info instead of top-level from/to
    String from = (json['from'] as String?) ?? '';
    String to = (json['to'] as String?) ?? '';

    final dynamic rawRoute = json['route'];
    if (rawRoute is Map<String, dynamic>) {
      // route.from / route.to can be either string or object with name
      final dynamic rawFrom = rawRoute['from'];
      final dynamic rawTo = rawRoute['to'];

      if ((from.isEmpty || from == 'N/A') && rawFrom != null) {
        if (rawFrom is Map<String, dynamic>) {
          from = rawFrom['name'] as String? ?? from;
        } else if (rawFrom is String) {
          from = rawFrom;
        }
      }

      if ((to.isEmpty || to == 'N/A') && rawTo != null) {
        if (rawTo is Map<String, dynamic>) {
          to = rawTo['name'] as String? ?? to;
        } else if (rawTo is String) {
          to = rawTo;
        }
      }
    }

    // Final safety fallback
    from = from.isEmpty ? 'Unknown' : from;
    to = to.isEmpty ? 'Unknown' : to;

    return BusModel(
      id: json['_id'] as String? ?? json['id'] as String,
      name: json['name'] as String,
      vehicleNumber: json['vehicleNumber'] as String? ?? '',
      from: from,
      to: to,
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String,
      arrival: json['arrival'] as String?,
      timeFormat: json['timeFormat'] as String?,
      arrivalFormat: json['arrivalFormat'] as String?,
      tripDirection: json['tripDirection'] as String?,
      tripStatus: json['tripStatus'] as String?,
      reachedAt: parseDateString(json['reachedAt']),
      price: (json['price'] as num).toDouble(),
      totalSeats: json['totalSeats'] as int,
      busType: json['busType'] as String?,
      driverContact: json['driverContact'] as String?,
      driverId: parseDriverId(json['driverId']),
      driverEmail: json['driverEmail'] as String?,
      driverName: json['driverName'] as String?,
      commissionRate: (json['commissionRate'] as num?)?.toDouble(),
      ownerId: json['ownerId'] as String?,
      ownerEmail: json['ownerEmail'] as String?,
      accessId: json['accessId'] as String?,
      allowedSeats: (json['allowedSeats'] as List<dynamic>?)
          ?.map((e) {
            if (e is int) return e;
            if (e is String) return int.tryParse(e);
            if (e is num) return e.toInt();
            return null;
          })
          .whereType<int>()
          .toList(),
      seatConfiguration: (json['seatConfiguration'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      amenities: parseAmenities(json['amenities']),
      boardingPoints: parsePoints(json['boardingPoints']),
      droppingPoints: parsePoints(json['droppingPoints']),
      routeId: json['routeId'] as String?,
      scheduleId: json['scheduleId'] as String?,
      parentBusId: json['parentBusId'] as String?,
      recurringScheduleId: json['recurringScheduleId'] as String?,
      distance: (json['distance'] as num?)?.toDouble(),
      estimatedDuration: json['estimatedDuration'] as int?,
      mainImageUrl: json['mainImageUrl'] as String?,
      galleryImages: (json['galleryImages'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      isActive: json['isActive'] as bool? ?? true,
      isRecurring: json['isRecurring'] as bool?,
      recurringDays: parseRecurringDays(json['recurringDays']),
      recurringStartDate: parseDateString(json['recurringStartDate']),
      recurringEndDate: parseDateString(json['recurringEndDate']),
      recurringFrequency: json['recurringFrequency'] as String?,
      autoActivate: json['autoActivate'] as bool?,
      activeFromDate: parseDateString(json['activeFromDate']),
      activeToDate: parseDateString(json['activeToDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'vehicleNumber': vehicleNumber,
      'from': from,
      'to': to,
      'date': date.toIso8601String().split('T')[0], // Format as YYYY-MM-DD
      'time': time,
      if (arrival != null) 'arrival': arrival,
      if (timeFormat != null) 'timeFormat': timeFormat,
      if (arrivalFormat != null) 'arrivalFormat': arrivalFormat,
      if (tripDirection != null) 'tripDirection': tripDirection,
      if (tripStatus != null) 'tripStatus': tripStatus,
      if (reachedAt != null) 'reachedAt': reachedAt!.toIso8601String(),
      'price': price,
      'totalSeats': totalSeats,
      if (busType != null) 'busType': busType,
      if (driverContact != null) 'driverContact': driverContact,
      if (driverId != null) 'driverId': driverId,
      if (driverEmail != null) 'driverEmail': driverEmail,
      if (driverName != null) 'driverName': driverName,
      if (commissionRate != null) 'commissionRate': commissionRate,
      if (allowedSeats != null) 'allowedSeats': allowedSeats,
      if (seatConfiguration != null) 'seatConfiguration': seatConfiguration,
      if (amenities != null) 'amenities': amenities,
      if (boardingPoints != null) 'boardingPoints': boardingPoints,
      if (droppingPoints != null) 'droppingPoints': droppingPoints,
      if (routeId != null) 'routeId': routeId,
      if (scheduleId != null) 'scheduleId': scheduleId,
      if (parentBusId != null) 'parentBusId': parentBusId,
      if (recurringScheduleId != null) 'recurringScheduleId': recurringScheduleId,
      if (distance != null) 'distance': distance,
      if (estimatedDuration != null) 'estimatedDuration': estimatedDuration,
      if (mainImageUrl != null) 'mainImageUrl': mainImageUrl,
      if (galleryImages != null) 'galleryImages': galleryImages,
      if (isRecurring != null) 'isRecurring': isRecurring,
      if (recurringDays != null) 'recurringDays': recurringDays,
      if (recurringStartDate != null) 'recurringStartDate': recurringStartDate!.toIso8601String().split('T')[0],
      if (recurringEndDate != null) 'recurringEndDate': recurringEndDate!.toIso8601String().split('T')[0],
      if (recurringFrequency != null) 'recurringFrequency': recurringFrequency,
      if (autoActivate != null) 'autoActivate': autoActivate,
      if (activeFromDate != null) 'activeFromDate': activeFromDate!.toIso8601String().split('T')[0],
      if (activeToDate != null) 'activeToDate': activeToDate!.toIso8601String().split('T')[0],
    };
  }
}

