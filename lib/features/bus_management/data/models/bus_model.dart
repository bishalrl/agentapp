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
    required super.price,
    required super.totalSeats,
    super.busType,
    super.driverContact,
    super.driverId,
    super.commissionRate,
    super.ownerId,
    super.ownerEmail,
    super.allowedSeats,
    super.isActive,
  });

  factory BusModel.fromJson(Map<String, dynamic> json) {
    print('🔍 BusModel.fromJson: Parsing JSON');
    print('   JSON keys: ${json.keys}');
    
    return BusModel(
      id: json['_id'] as String? ?? json['id'] as String,
      name: json['name'] as String,
      vehicleNumber: json['vehicleNumber'] as String? ?? json['vehicleNumber'] as String? ?? '',
      from: json['from'] as String,
      to: json['to'] as String,
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String,
      arrival: json['arrival'] as String?,
      price: (json['price'] as num).toDouble(),
      totalSeats: json['totalSeats'] as int,
      busType: json['busType'] as String?,
      driverContact: json['driverContact'] as String?,
      driverId: json['driverId'] as String?,
      commissionRate: (json['commissionRate'] as num?)?.toDouble(),
      ownerId: json['ownerId'] as String?,
      ownerEmail: json['ownerEmail'] as String?,
      allowedSeats: (json['allowedSeats'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      isActive: json['isActive'] as bool? ?? true,
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
      'price': price,
      'totalSeats': totalSeats,
      if (busType != null) 'busType': busType,
      if (driverContact != null) 'driverContact': driverContact,
      if (driverId != null) 'driverId': driverId,
      if (commissionRate != null) 'commissionRate': commissionRate,
      if (allowedSeats != null) 'allowedSeats': allowedSeats,
    };
  }
}

