import '../../../../../core/bloc/base_bloc_event.dart';

abstract class BusEvent extends BaseBlocEvent {
  const BusEvent();
}

class CreateBusEvent extends BusEvent {
  final String name;
  final String vehicleNumber;
  final String from;
  final String to;
  final DateTime date;
  final String time;
  final String? arrival;
  final double price;
  final int totalSeats;
  final String? busType;
  final String? driverContact;
  final double? commissionRate;
  final List<int>? allowedSeats;

  const CreateBusEvent({
    required this.name,
    required this.vehicleNumber,
    required this.from,
    required this.to,
    required this.date,
    required this.time,
    this.arrival,
    required this.price,
    required this.totalSeats,
    this.busType,
    this.driverContact,
    this.commissionRate,
    this.allowedSeats,
  });

  @override
  List<Object?> get props => [
        name,
        vehicleNumber,
        from,
        to,
        date,
        time,
        arrival,
        price,
        totalSeats,
        busType,
        driverContact,
        commissionRate,
        allowedSeats,
      ];
}

class UpdateBusEvent extends BusEvent {
  final String busId;
  final String? name;
  final String? vehicleNumber;
  final String? from;
  final String? to;
  final DateTime? date;
  final String? time;
  final String? arrival;
  final double? price;
  final int? totalSeats;
  final String? busType;
  final String? driverContact;
  final double? commissionRate;
  final List<int>? allowedSeats;

  const UpdateBusEvent({
    required this.busId,
    this.name,
    this.vehicleNumber,
    this.from,
    this.to,
    this.date,
    this.time,
    this.arrival,
    this.price,
    this.totalSeats,
    this.busType,
    this.driverContact,
    this.commissionRate,
    this.allowedSeats,
  });

  @override
  List<Object?> get props => [
        busId,
        name,
        vehicleNumber,
        from,
        to,
        date,
        time,
        arrival,
        price,
        totalSeats,
        busType,
        driverContact,
        commissionRate,
        allowedSeats,
      ];
}

class DeleteBusEvent extends BusEvent {
  final String busId;

  const DeleteBusEvent({required this.busId});

  @override
  List<Object?> get props => [busId];
}

class GetMyBusesEvent extends BusEvent {
  final String? date;
  final String? route;
  final String? status;

  const GetMyBusesEvent({
    this.date,
    this.route,
    this.status,
  });

  @override
  List<Object?> get props => [date, route, status];
}

class ActivateBusEvent extends BusEvent {
  final String busId;

  const ActivateBusEvent({required this.busId});

  @override
  List<Object?> get props => [busId];
}

class DeactivateBusEvent extends BusEvent {
  final String busId;

  const DeactivateBusEvent({required this.busId});

  @override
  List<Object?> get props => [busId];
}

