import '../../domain/entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.ticketNumber,
    required super.busId,
    required super.bus,
    required super.seatNumbers,
    required super.passengerName,
    required super.contactNumber,
    super.passengerEmail,
    super.pickupLocation,
    super.dropoffLocation,
    super.luggage,
    super.bagCount,
    required super.price,
    required super.totalPrice,
    required super.status,
    required super.paymentMethod,
    required super.createdAt,
  });
  
  factory BookingModel.fromJson(Map<String, dynamic> json) {
    print('🔍 BookingModel.fromJson: Parsing booking');
    print('   JSON keys: ${json.keys}');
    
    // Extract bus data with fallback handling
    final itemId = json['itemId'] as Map<String, dynamic>?;
    final busData = json['bus'] as Map<String, dynamic>?;
    final busInfo = itemId ?? busData;
    
    // Handle fallback values when bus data is missing
    BusInfoModel bus;
    String busId;
    
    if (busInfo is Map<String, dynamic>) {
      // Bus data is available
      busId = busInfo['_id'] as String? ?? busInfo['id'] as String? ?? json['busId'] as String? ?? '';
      print('   ✅ Bus data available, parsing normally');
      bus = BusInfoModel.fromJson(busInfo);
    } else {
      // Bus data is missing, use fallback values
      busId = json['busId'] as String? ?? '';
      print('   ⚠️ Bus data missing, using fallback values');
      
      // Use fallback values from booking
      final originalDate = json['originalBookingDate'] as String?;
      final originalTime = json['originalBookingTime'] as String?;
      final originalRoute = json['originalRoute'] as String?;
      
      // Parse route for from/to if available (format: "From → To" or just route name)
      String from = 'Unknown';
      String to = 'Unknown';
      if (originalRoute != null) {
        if (originalRoute.contains('→')) {
          final parts = originalRoute.split('→');
          from = parts[0].trim();
          to = parts.length > 1 ? parts[1].trim() : 'Unknown';
        } else {
          from = originalRoute;
        }
      }
      
      // Create minimal bus info with fallback values
      bus = BusInfoModel(
        id: busId.isNotEmpty ? busId : 'unknown',
        name: 'Bus (Details Unavailable)',
        from: from,
        to: to,
        date: originalDate != null 
            ? DateTime.tryParse(originalDate) ?? DateTime.now()
            : DateTime.now(),
        time: originalTime ?? 'N/A',
        arrival: null,
        price: BusInfoModel._parseToDouble(json['price']),
        totalSeats: 0,
        filledSeats: 0,
        availableSeats: 0,
        bookedSeats: [],
        lockedSeats: [],
      );
    }
    
    // Handle seatNumbers - can be array or single number/string
    // Supports both int (legacy) and String (new flexible format)
    List<dynamic> seatNumbers;
    if (json['seatNumbers'] != null) {
      if (json['seatNumbers'] is List) {
        seatNumbers = (json['seatNumbers'] as List<dynamic>).map((e) {
          // Support both int and String
          if (e is num) return e.toInt();
          if (e is String) return e;
          return e.toString();
        }).toList();
      } else {
        final seat = json['seatNumbers'];
        if (seat is num) {
          seatNumbers = [seat.toInt()];
        } else {
          seatNumbers = [seat.toString()];
        }
      }
    } else if (json['seatNumber'] != null) {
      final seat = json['seatNumber'];
      if (seat is num) {
        seatNumbers = [seat.toInt()];
      } else {
        seatNumbers = [seat.toString()];
      }
    } else {
      seatNumbers = [];
    }
    
    // Handle id - can be null, generate a fallback if needed
    final id = json['_id'] as String? ?? 
               json['id'] as String? ?? 
               'booking_${DateTime.now().millisecondsSinceEpoch}';
    
    return BookingModel(
      id: id,
      ticketNumber: json['ticketNumber'] as String? ?? 'N/A',
      busId: busId,
      bus: bus,
      seatNumbers: seatNumbers,
      passengerName: json['passengerName'] as String? ?? '',
      contactNumber: json['contactNumber'] as String? ?? '',
      passengerEmail: json['passengerEmail'] as String?,
      pickupLocation: json['pickupLocation'] as String?,
      dropoffLocation: json['dropoffLocation'] as String?,
      luggage: json['luggage'] as String?,
      bagCount: json['bagCount'] != null 
          ? ((json['bagCount'] is num) 
              ? (json['bagCount'] as num).toInt() 
              : int.tryParse(json['bagCount'].toString()))
          : null,
      price: BusInfoModel._parseToDouble(json['price']),
      totalPrice: BusInfoModel._parseToDouble(json['totalPrice']) != 0.0
          ? BusInfoModel._parseToDouble(json['totalPrice'])
          : BusInfoModel._parseToDouble(json['price']),
      status: json['status'] as String? ?? 'pending',
      paymentMethod: json['details']?['paymentMethod'] as String? ?? 
                     json['paymentMethod'] as String? ?? 
                     'cash',
      createdAt: json['createdAt'] != null 
          ? (DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now())
          : (json['createdAt'] != null 
              ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
              : DateTime.now()),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticketNumber': ticketNumber,
      'busId': busId,
      'bus': (bus as BusInfoModel).toJson(),
      'seatNumbers': seatNumbers,
      'passengerName': passengerName,
      'contactNumber': contactNumber,
      'passengerEmail': passengerEmail,
      'pickupLocation': pickupLocation,
      'dropoffLocation': dropoffLocation,
      'luggage': luggage,
      'bagCount': bagCount,
      'price': price,
      'totalPrice': totalPrice,
      'status': status,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class BusInfoModel extends BusInfoEntity {
  const BusInfoModel({
    required super.id,
    required super.name,
    required super.from,
    required super.to,
    required super.date,
    required super.time,
    super.arrival,
    required super.price,
    required super.totalSeats,
    required super.filledSeats,
    required super.availableSeats,
    required super.bookedSeats,
    required super.lockedSeats,
    super.seatConfiguration,
    super.accessId,
    super.allowedSeats,
    super.hasAccess,
    super.allowedSeatsCount,
    super.hasRestrictedAccess,
    super.requiresWallet,
    super.hasNoAccess,
    super.availableAllowedSeats,
    super.availableAllowedSeatsCount,
  });
  
  // Helper methods for parsing numeric values that might be strings
  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
    return 0.0;
  }
  
  static int? _parseToInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    return null;
  }
  
  factory BusInfoModel.fromJson(Map<String, dynamic> json) {
    print('🔍 BusInfoModel.fromJson: Parsing bus');
    print('   JSON keys: ${json.keys}');
    
    try {
      // Handle date parsing with fallback
      DateTime parseDate(String? dateStr) {
        if (dateStr == null) return DateTime.now();
        try {
          return DateTime.parse(dateStr);
        } catch (e) {
          print('   ⚠️ Failed to parse date: $dateStr, using now()');
          return DateTime.now();
        }
      }
      
      // Route fallback: prefer top-level from/to, but support nested route object
      String from = json['from'] as String? ?? '';
      String to = json['to'] as String? ?? '';

      final dynamic rawRoute = json['route'];
      if (rawRoute is Map<String, dynamic>) {
        final dynamic rawFrom = rawRoute['from'];
        final dynamic rawTo = rawRoute['to'];

        if ((from.isEmpty || from == 'Unknown' || from == 'N/A') && rawFrom != null) {
          if (rawFrom is Map<String, dynamic>) {
            from = rawFrom['name'] as String? ?? from;
          } else if (rawFrom is String) {
            from = rawFrom;
          }
        }

        if ((to.isEmpty || to == 'Unknown' || to == 'N/A') && rawTo != null) {
          if (rawTo is Map<String, dynamic>) {
            to = rawTo['name'] as String? ?? to;
          } else if (rawTo is String) {
            to = rawTo;
          }
        }
      }

      from = from.isEmpty ? 'Unknown' : from;
      to = to.isEmpty ? 'Unknown' : to;

      return BusInfoModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? 'unknown',
      name: json['name'] as String? ?? 'Unknown Bus',
      from: from,
      to: to,
      date: parseDate(json['date'] as String?),
      time: json['time'] as String? ?? 'N/A',
      arrival: json['arrival'] as String?,
      price: _parseToDouble(json['price']),
      totalSeats: _parseToInt(json['totalSeats']) ?? 0,
      filledSeats: _parseToInt(json['filledSeats']) ?? 0,
      availableSeats: _parseToInt(json['availableSeats']) ?? 
                      _parseToInt(json['totalSeats']) ?? 0,
      bookedSeats: (json['bookedSeats'] as List<dynamic>?)
          ?.map((e) {
            // Support both int (legacy) and String (new format)
            if (e is num) return e.toInt();
            if (e is String) return e;
            return e.toString();
          })
          .toList() ?? [],
      lockedSeats: (json['lockedSeats'] as List<dynamic>?)
          ?.map((e) {
            try {
              return SeatLockModel.fromJson(e as Map<String, dynamic>);
            } catch (e) {
              print('   ⚠️ Failed to parse seat lock: $e');
              return null;
            }
          })
          .whereType<SeatLockModel>()
          .toList()
          .cast<SeatLockEntity>() ?? [],
      seatConfiguration: (json['seatConfiguration'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      accessId: json['accessId'] as String?,
      hasAccess: json['hasAccess'] as bool?,
      allowedSeats: (json['allowedSeats'] as List<dynamic>?)
          ?.map<int>((e) {
            // Handle both String and num types for allowedSeats
            // Convert everything to int for consistency
            if (e is num) return e.toInt();
            if (e is String) {
              // Try to parse as int, fallback to 0 if can't parse
              final parsed = int.tryParse(e);
              return parsed ?? 0;
            }
            // Try to convert to int, fallback to 0
            if (e is int) return e;
            return 0;
          })
          .toList(),
      // New backend fields for enhanced seat access management
      allowedSeatsCount: _parseToInt(json['allowedSeatsCount']),
      hasRestrictedAccess: json['hasRestrictedAccess'] as bool?,
      requiresWallet: json['requiresWallet'] as bool?,
      hasNoAccess: json['hasNoAccess'] as bool?,
      availableAllowedSeats: (json['availableAllowedSeats'] as List<dynamic>?)
          ?.map<int>((e) {
            if (e is num) return e.toInt();
            if (e is String) {
              final parsed = int.tryParse(e);
              return parsed ?? 0;
            }
            if (e is int) return e;
            return 0;
          })
          .toList(),
      availableAllowedSeatsCount: _parseToInt(json['availableAllowedSeatsCount']),
      );
    } catch (e, stackTrace) {
      print('   ❌ Error parsing BusInfoModel: $e');
      print('   Stack trace: $stackTrace');
      print('   Problematic JSON: $json');
      // Re-throw with more context
      throw Exception('Failed to parse BusInfoModel: $e. JSON keys: ${json.keys}');
    }
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'from': from,
      'to': to,
      'date': date.toIso8601String(),
      'time': time,
      'arrival': arrival,
      'price': price,
      'totalSeats': totalSeats,
      'filledSeats': filledSeats,
      'availableSeats': availableSeats,
      'bookedSeats': bookedSeats,
      'lockedSeats': lockedSeats.map((e) => (e as SeatLockModel).toJson()).toList(),
      if (seatConfiguration != null) 'seatConfiguration': seatConfiguration,
    };
  }
}

class SeatLockModel extends SeatLockEntity {
  const SeatLockModel({
    required super.seatNumber,
    required super.lockedBy,
    required super.lockedByType,
    required super.expiresAt,
  });
  
  factory SeatLockModel.fromJson(Map<String, dynamic> json) {
    // Handle expiresAt with null safety
    DateTime parseExpiresAt(dynamic expiresAtValue) {
      if (expiresAtValue == null) {
        return DateTime.now().add(const Duration(hours: 1)); // Default 1 hour from now
      }
      if (expiresAtValue is String) {
        final parsed = DateTime.tryParse(expiresAtValue);
        if (parsed != null) return parsed;
      }
      return DateTime.now().add(const Duration(hours: 1));
    }
    
    // Support both int (legacy) and String (new format) for seatNumber
    dynamic seatNumber;
    final seatNumberValue = json['seatNumber'];
    if (seatNumberValue is num) {
      seatNumber = seatNumberValue.toInt();
    } else if (seatNumberValue is String) {
      seatNumber = seatNumberValue;
    } else if (seatNumberValue != null) {
      seatNumber = seatNumberValue.toString();
    } else {
      seatNumber = 0; // Default fallback
    }
    
    return SeatLockModel(
      seatNumber: seatNumber,
      lockedBy: json['lockedBy'] as String? ?? 
                json['lockedByUser']?['_id'] as String? ?? 
                json['lockedByUser'] as String? ?? 
                '',
      lockedByType: json['lockedByType'] as String? ?? 'User',
      expiresAt: parseExpiresAt(json['expiresAt']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'seatNumber': seatNumber,
      'lockedBy': lockedBy,
      'lockedByType': lockedByType,
      'expiresAt': expiresAt.toIso8601String(),
    };
  }
}

