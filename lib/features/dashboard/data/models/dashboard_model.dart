import '../../domain/entities/dashboard_entity.dart';

class DashboardModel extends DashboardEntity {
  const DashboardModel({
    required super.counter,
    required super.assignedBuses,
    required super.todayStats,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final counterData = json['counter'] as Map<String, dynamic>;
    final counter = CounterModel.fromJson(counterData);

    final assignedBusesData = json['assignedBuses'] as Map<String, dynamic>;
    final assignedBuses = <String, Map<String, RouteBusesEntity>>{};

    assignedBusesData.forEach((date, routesData) {
      final routes = routesData as Map<String, dynamic>;
      final routeMap = <String, RouteBusesEntity>{};

      routes.forEach((routeKey, routeData) {
        routeMap[routeKey] = RouteBusesModel.fromJson(routeData as Map<String, dynamic>);
      });

      assignedBuses[date] = routeMap;
    });

    final todayStats = TodayStatsModel.fromJson(json['todayStats'] as Map<String, dynamic>);

    return DashboardModel(
      counter: counter,
      assignedBuses: assignedBuses,
      todayStats: todayStats,
    );
  }
}

class CounterModel extends CounterEntity {
  const CounterModel({
    required super.id,
    required super.agencyName,
    required super.email,
    required super.walletBalance,
  });

  factory CounterModel.fromJson(Map<String, dynamic> json) {
    return CounterModel(
      id: json['id'] as String,
      agencyName: json['agencyName'] as String,
      email: json['email'] as String,
      walletBalance: (json['walletBalance'] as num).toDouble(),
    );
  }
}

class RouteBusesModel extends RouteBusesEntity {
  const RouteBusesModel({
    required super.route,
    required super.buses,
  });

  factory RouteBusesModel.fromJson(Map<String, dynamic> json) {
    final route = RouteModel.fromJson(json['route'] as Map<String, dynamic>);
    final buses = (json['buses'] as List<dynamic>)
        .map((bus) => BusInfoModel.fromJson(bus as Map<String, dynamic>))
        .toList();

    return RouteBusesModel(route: route, buses: buses);
  }
}

class RouteModel extends RouteEntity {
  const RouteModel({
    required super.from,
    required super.to,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      from: json['from'] as String,
      to: json['to'] as String,
    );
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
    required super.price,
    required super.totalSeats,
    super.accessId,
    required super.allowedSeats,
    required super.commissionEarned,
    required super.totalBookings,
  });

  factory BusInfoModel.fromJson(Map<String, dynamic> json) {
    return BusInfoModel(
      id: json['_id'] as String? ?? json['id'] as String,
      name: json['name'] as String,
      from: json['from'] as String,
      to: json['to'] as String,
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String,
      price: (json['price'] as num).toDouble(),
      totalSeats: json['totalSeats'] as int,
      accessId: json['accessId'] as String?,
      allowedSeats: (json['allowedSeats'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      commissionEarned: (json['commissionEarned'] as num?)?.toDouble() ?? 0.0,
      totalBookings: json['totalBookings'] as int? ?? 0,
    );
  }
}

class TodayStatsModel extends TodayStatsEntity {
  const TodayStatsModel({
    required super.totalBookings,
    required super.totalSales,
    required super.cashSales,
    required super.onlineSales,
    required super.busesWithBookings,
  });

  factory TodayStatsModel.fromJson(Map<String, dynamic> json) {
    return TodayStatsModel(
      totalBookings: json['totalBookings'] as int? ?? 0,
      totalSales: (json['totalSales'] as num?)?.toDouble() ?? 0.0,
      cashSales: (json['cashSales'] as num?)?.toDouble() ?? 0.0,
      onlineSales: (json['onlineSales'] as num?)?.toDouble() ?? 0.0,
      busesWithBookings: json['busesWithBookings'] as int? ?? 0,
    );
  }
}

