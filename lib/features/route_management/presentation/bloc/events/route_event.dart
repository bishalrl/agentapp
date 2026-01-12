import '../../../../../core/bloc/base_bloc_event.dart';

abstract class RouteEvent extends BaseBlocEvent {
  const RouteEvent();
}

class CreateRouteEvent extends RouteEvent {
  final String from;
  final String to;
  final double? distance;
  final int? estimatedDuration;
  final String? description;

  const CreateRouteEvent({
    required this.from,
    required this.to,
    this.distance,
    this.estimatedDuration,
    this.description,
  });

  @override
  List<Object?> get props => [from, to, distance, estimatedDuration, description];
}

class UpdateRouteEvent extends RouteEvent {
  final String routeId;
  final String? from;
  final String? to;
  final double? distance;
  final int? estimatedDuration;
  final String? description;

  const UpdateRouteEvent({
    required this.routeId,
    this.from,
    this.to,
    this.distance,
    this.estimatedDuration,
    this.description,
  });

  @override
  List<Object?> get props => [routeId, from, to, distance, estimatedDuration, description];
}

class DeleteRouteEvent extends RouteEvent {
  final String routeId;

  const DeleteRouteEvent({required this.routeId});

  @override
  List<Object?> get props => [routeId];
}

class GetRoutesEvent extends RouteEvent {
  final String? search;

  const GetRoutesEvent({this.search});

  @override
  List<Object?> get props => [search];
}

class GetRouteByIdEvent extends RouteEvent {
  final String routeId;

  const GetRouteByIdEvent({required this.routeId});

  @override
  List<Object?> get props => [routeId];
}

