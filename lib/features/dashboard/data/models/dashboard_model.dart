import '../../domain/entities/dashboard_entity.dart';

class DashboardModel extends DashboardEntity {
  const DashboardModel({
    required super.counter,
    required super.assignedBuses,
    required super.todayStats,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final counterData = json['counter'] as Map<String, dynamic>?;
    if (counterData == null) {
      throw Exception('Counter data is missing in dashboard response');
    }
    final counter = CounterModel.fromJson(counterData);

    // Handle both array and nested object formats for assignedBuses
    final assignedBusesData = json['assignedBuses'];
    final assignedBuses = <String, Map<String, RouteBusesEntity>>{};

    if (assignedBusesData is List) {
      // New format: Array of bus objects
      // Group them by date and route
      final Map<String, Map<String, List<BusInfoEntity>>> grouped = {};
      
      for (var item in assignedBusesData) {
        if (item is! Map<String, dynamic>) continue;
        
        final busIdData = item['busId'] as Map<String, dynamic>?;
        if (busIdData == null) continue;
        
        final bus = BusInfoModel.fromJson({
          ...busIdData,
          'accessId': item['accessId'],
          'allowedSeats': item['allowedSeats'] ?? [],
          'commissionEarned': item['commissionEarned'] ?? 0.0,
          'totalBookings': item['totalBookings'] ?? 0,
        });
        
        final dateStr = bus.date.toIso8601String().split('T')[0]; // YYYY-MM-DD
        final routeKey = '${bus.from}-${bus.to}';
        
        grouped.putIfAbsent(dateStr, () => {});
        grouped[dateStr]!.putIfAbsent(routeKey, () => []);
        grouped[dateStr]![routeKey]!.add(bus);
      }
      
      // Convert to expected structure
      grouped.forEach((date, routes) {
        final routeMap = <String, RouteBusesEntity>{};
        routes.forEach((routeKey, buses) {
          if (buses.isNotEmpty) {
            final firstBus = buses.first;
            routeMap[routeKey] = RouteBusesModel(
              route: RouteModel(from: firstBus.from, to: firstBus.to),
              buses: buses,
            );
          }
        });
        assignedBuses[date] = routeMap;
      });
    } else if (assignedBusesData is Map<String, dynamic>) {
      // Old format: Nested object (date → route → buses)
      assignedBusesData.forEach((date, routesData) {
        if (routesData is! Map<String, dynamic>) return;
        final routes = routesData;
        final routeMap = <String, RouteBusesEntity>{};

        routes.forEach((routeKey, routeData) {
          if (routeData is Map<String, dynamic>) {
            routeMap[routeKey] = RouteBusesModel.fromJson(routeData);
          }
        });

        assignedBuses[date] = routeMap;
      });
    }

    final todayStatsData = json['todayStats'] as Map<String, dynamic>?;
    if (todayStatsData == null) {
      throw Exception('Today stats data is missing in dashboard response');
    }
    final todayStats = TodayStatsModel.fromJson(todayStatsData);

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
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      agencyName: json['agencyName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class RouteBusesModel extends RouteBusesEntity {
  const RouteBusesModel({
    required super.route,
    required super.buses,
  });

  factory RouteBusesModel.fromJson(Map<String, dynamic> json) {
    final routeData = json['route'] as Map<String, dynamic>?;
    if (routeData == null) {
      throw Exception('Route data is missing in RouteBusesModel');
    }
    final route = RouteModel.fromJson(routeData);
    
    final busesData = json['buses'] as List<dynamic>?;
    final buses = (busesData ?? [])
        .map((bus) {
          if (bus is Map<String, dynamic>) {
            return BusInfoModel.fromJson(bus);
          }
          return null;
        })
        .whereType<BusInfoModel>()
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
    // Handle date parsing with fallback
    DateTime parseDate(dynamic dateValue) {
      if (dateValue is String) {
        try {
          return DateTime.parse(dateValue);
        } catch (e) {
          return DateTime.now();
        }
      } else if (dateValue is DateTime) {
        return dateValue;
      }
      return DateTime.now();
    }

    // Handle allowedSeats - can be array of int or array of strings
    List<int> parseAllowedSeats(dynamic seats) {
      if (seats == null) return [];
      if (seats is! List) return [];
      return seats.map((e) {
        if (e is int) return e;
        if (e is String) return int.tryParse(e) ?? 0;
        if (e is num) return e.toInt();
        return 0;
      }).where((e) => e > 0).toList();
    }

    // Helper methods for parsing numeric values that might be strings
    double parseToDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        if (parsed != null) return parsed;
      }
      return 0.0;
    }
    
    int parseToInt(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
      return 0;
    }
    
    return BusInfoModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown Bus',
      from: json['from'] as String? ?? 'Unknown',
      to: json['to'] as String? ?? 'Unknown',
      date: parseDate(json['date']),
      time: json['time'] as String? ?? 'N/A',
      price: parseToDouble(json['price']),
      totalSeats: parseToInt(json['totalSeats']),
      accessId: json['accessId'] as String?,
      allowedSeats: parseAllowedSeats(json['allowedSeats']),
      commissionEarned: parseToDouble(json['commissionEarned']),
      totalBookings: parseToInt(json['totalBookings']),
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

