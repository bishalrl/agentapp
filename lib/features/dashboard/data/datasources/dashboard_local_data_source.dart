import 'dart:convert';
import 'package:agentapp/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/dashboard_model.dart';

abstract class DashboardLocalDataSource {
  Future<DashboardModel?> getCachedDashboard();
  Future<void> cacheDashboard(DashboardModel dashboard);
  Future<void> clearCache();
  Future<DateTime?> getLastCacheTime();
}

class DashboardLocalDataSourceImpl implements DashboardLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _cacheKey = 'cached_dashboard';
  static const String _cacheTimeKey = 'dashboard_cache_time';
  static const Duration _cacheValidityDuration = Duration(minutes: 30); // Cache valid for 30 minutes

  DashboardLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<DashboardModel?> getCachedDashboard() async {
    try {
      final cacheTime = await getLastCacheTime();
      if (cacheTime == null) {
        return null;
      }

      // Check if cache is still valid
      final now = DateTime.now();
      if (now.difference(cacheTime) > _cacheValidityDuration) {
        return null;
      }

      final cachedData = sharedPreferences.getString(_cacheKey);
      if (cachedData == null || cachedData.isEmpty) {
        return null;
      }

      final json = jsonDecode(cachedData) as Map<String, dynamic>;
      return DashboardModel.fromJson(json);
    } catch (e) {
      // Return null on error, don't throw
      return null;
    }
  }

  @override
  Future<void> cacheDashboard(DashboardModel dashboard) async {
    try {
      // Convert dashboard to JSON manually since there's no toJson method
      final json = {
        'counter': {
          'id': dashboard.counter.id,
          'agencyName': dashboard.counter.agencyName,
          'email': dashboard.counter.email,
          'walletBalance': dashboard.counter.walletBalance,
        },
        'assignedBuses': _serializeAssignedBuses(dashboard.assignedBuses),
        'todayStats': {
          'totalBookings': dashboard.todayStats.totalBookings,
          'totalSales': dashboard.todayStats.totalSales,
          'cashSales': dashboard.todayStats.cashSales,
          'onlineSales': dashboard.todayStats.onlineSales,
          'busesWithBookings': dashboard.todayStats.busesWithBookings,
        },
      };
      final jsonString = jsonEncode(json);
      await sharedPreferences.setString(_cacheKey, jsonString);
      await sharedPreferences.setString(_cacheTimeKey, DateTime.now().toIso8601String());
    } catch (e) {
      throw CacheException('Failed to cache dashboard: ${e.toString()}');
    }
  }

  Map<String, dynamic> _serializeAssignedBuses(Map<String, Map<String, RouteBusesEntity>> assignedBuses) {
    final result = <String, dynamic>{};
    assignedBuses.forEach((date, routes) {
      final routesMap = <String, dynamic>{};
      routes.forEach((routeKey, routeBuses) {
        routesMap[routeKey] = {
          'route': {
            'from': routeBuses.route.from,
            'to': routeBuses.route.to,
          },
          'buses': routeBuses.buses.map((bus) => {
            'id': bus.id,
            'name': bus.name,
            'from': bus.from,
            'to': bus.to,
            'date': bus.date.toIso8601String(),
            'time': bus.time,
            'price': bus.price,
            'totalSeats': bus.totalSeats,
            'accessId': bus.accessId,
            'allowedSeats': bus.allowedSeats,
            'commissionEarned': bus.commissionEarned,
            'totalBookings': bus.totalBookings,
          }).toList(),
        };
      });
      result[date] = routesMap;
    });
    return result;
  }

  @override
  Future<void> clearCache() async {
    try {
      await sharedPreferences.remove(_cacheKey);
      await sharedPreferences.remove(_cacheTimeKey);
    } catch (e) {
      throw CacheException('Failed to clear cache: ${e.toString()}');
    }
  }

  @override
  Future<DateTime?> getLastCacheTime() async {
    try {
      final cacheTimeString = sharedPreferences.getString(_cacheTimeKey);
      if (cacheTimeString == null || cacheTimeString.isEmpty) {
        return null;
      }
      return DateTime.parse(cacheTimeString);
    } catch (e) {
      return null;
    }
  }
}
