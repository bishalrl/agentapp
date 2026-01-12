class ScheduleEntity {
  final String id;
  final String routeId;
  final String? busId;
  final String departureTime;
  final String arrivalTime;
  final List<String> daysOfWeek;
  final bool isActive;

  ScheduleEntity({
    required this.id,
    required this.routeId,
    this.busId,
    required this.departureTime,
    required this.arrivalTime,
    required this.daysOfWeek,
    required this.isActive,
  });
}
