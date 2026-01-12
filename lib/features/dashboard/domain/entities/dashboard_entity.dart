// BusInfoEntity is defined in this file

class DashboardEntity {
  final CounterEntity counter;
  final Map<String, Map<String, RouteBusesEntity>> assignedBuses;
  final TodayStatsEntity todayStats;

  const DashboardEntity({
    required this.counter,
    required this.assignedBuses,
    required this.todayStats,
  });
}

class CounterEntity {
  final String id;
  final String agencyName;
  final String email;
  final double walletBalance;

  const CounterEntity({
    required this.id,
    required this.agencyName,
    required this.email,
    required this.walletBalance,
  });
}

class RouteBusesEntity {
  final RouteEntity route;
  final List<BusInfoEntity> buses;

  const RouteBusesEntity({
    required this.route,
    required this.buses,
  });
}

class RouteEntity {
  final String from;
  final String to;

  const RouteEntity({
    required this.from,
    required this.to,
  });
}

class BusInfoEntity {
  final String id;
  final String name;
  final String from;
  final String to;
  final DateTime date;
  final String time;
  final double price;
  final int totalSeats;
  final String? accessId;
  final List<int> allowedSeats;
  final double commissionEarned;
  final int totalBookings;

  const BusInfoEntity({
    required this.id,
    required this.name,
    required this.from,
    required this.to,
    required this.date,
    required this.time,
    required this.price,
    required this.totalSeats,
    this.accessId,
    required this.allowedSeats,
    required this.commissionEarned,
    required this.totalBookings,
  });
}

class TodayStatsEntity {
  final int totalBookings;
  final double totalSales;
  final double cashSales;
  final double onlineSales;
  final int busesWithBookings;

  const TodayStatsEntity({
    required this.totalBookings,
    required this.totalSales,
    required this.cashSales,
    required this.onlineSales,
    required this.busesWithBookings,
  });
}

