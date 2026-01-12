import '../../domain/entities/route_entity.dart';

class RouteModel extends RouteEntity {
  const RouteModel({
    required super.id,
    required super.from,
    required super.to,
    super.distance,
    super.estimatedDuration,
    super.description,
    super.createdBy,
    super.createdByType,
    super.createdAt,
    super.updatedAt,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    print('🔍 RouteModel.fromJson: Parsing JSON');
    print('   JSON keys: ${json.keys}');
    
    return RouteModel(
      id: json['_id'] as String? ?? json['id'] as String,
      from: json['from'] as String,
      to: json['to'] as String,
      distance: (json['distance'] as num?)?.toDouble(),
      estimatedDuration: json['estimatedDuration'] as int?,
      description: json['description'] as String?,
      createdBy: json['createdBy'] as String?,
      createdByType: json['createdByType'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'to': to,
      if (distance != null) 'distance': distance,
      if (estimatedDuration != null) 'estimatedDuration': estimatedDuration,
      if (description != null) 'description': description,
    };
  }
}

