class RouteEntity {
  final String id;
  final String from;
  final String to;
  final double? distance; // in kilometers
  final int? estimatedDuration; // in minutes
  final String? description;
  final String? createdBy;
  final String? createdByType; // 'Admin', 'BusOwner', 'BusAgent'
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  const RouteEntity({
    required this.id,
    required this.from,
    required this.to,
    this.distance,
    this.estimatedDuration,
    this.description,
    this.createdBy,
    this.createdByType,
    this.createdAt,
    this.updatedAt,
  });
  
  String get routeName => '$from → $to';
}

