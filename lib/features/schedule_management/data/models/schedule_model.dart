import '../../domain/entities/schedule_entity.dart';

class ScheduleModel extends ScheduleEntity {
  ScheduleModel({
    required super.id,
    required super.routeId,
    super.busId,
    required super.departureTime,
    required super.arrivalTime,
    required super.daysOfWeek,
    required super.isActive,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['_id'] ?? json['id'] ?? '',
      routeId: json['routeId'] ?? '',
      busId: json['busId'],
      departureTime: json['departureTime'] ?? '',
      arrivalTime: json['arrivalTime'] ?? '',
      daysOfWeek: json['daysOfWeek'] != null
          ? List<String>.from(json['daysOfWeek'])
          : [],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'routeId': routeId,
      if (busId != null) 'busId': busId,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'daysOfWeek': daysOfWeek,
      'isActive': isActive,
    };
  }
}
