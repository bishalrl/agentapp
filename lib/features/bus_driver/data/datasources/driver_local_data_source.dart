import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/driver_model.dart' show DriverModel, BusModel;

abstract class DriverLocalDataSource {
  Future<Map<String, dynamic>?> getCachedDriverDashboard();
  Future<void> cacheDriverDashboard(Map<String, dynamic> dashboard);
  Future<DriverModel?> getCachedDriverProfile();
  Future<void> cacheDriverProfile(DriverModel profile);
  Future<List<BusModel>> getCachedAssignedBuses();
  Future<void> cacheAssignedBuses(List<BusModel> buses);
  Future<void> clearCache();
  Future<DateTime?> getLastCacheTime(String cacheType);
}

class DriverLocalDataSourceImpl implements DriverLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _dashboardCacheKey = 'cached_driver_dashboard';
  static const String _dashboardCacheTimeKey = 'driver_dashboard_cache_time';
  static const String _profileCacheKey = 'cached_driver_profile';
  static const String _profileCacheTimeKey = 'driver_profile_cache_time';
  static const String _assignedBusesCacheKey = 'cached_driver_assigned_buses';
  static const String _assignedBusesCacheTimeKey = 'driver_assigned_buses_cache_time';
  static const Duration _cacheValidityDuration = Duration(hours: 1); // Cache valid for 1 hour

  DriverLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<Map<String, dynamic>?> getCachedDriverDashboard() async {
    try {
      final cacheTime = await getLastCacheTime('dashboard');
      if (cacheTime == null) {
        return null;
      }

      final now = DateTime.now();
      if (now.difference(cacheTime) > _cacheValidityDuration) {
        return null;
      }

      final cachedData = sharedPreferences.getString(_dashboardCacheKey);
      if (cachedData == null || cachedData.isEmpty) {
        return null;
      }

      return jsonDecode(cachedData) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheDriverDashboard(Map<String, dynamic> dashboard) async {
    try {
      final jsonString = jsonEncode(dashboard);
      await sharedPreferences.setString(_dashboardCacheKey, jsonString);
      await sharedPreferences.setString(_dashboardCacheTimeKey, DateTime.now().toIso8601String());
    } catch (e) {
      throw CacheException('Failed to cache driver dashboard: ${e.toString()}');
    }
  }

  @override
  Future<DriverModel?> getCachedDriverProfile() async {
    try {
      final cacheTime = await getLastCacheTime('profile');
      if (cacheTime == null) {
        return null;
      }

      final now = DateTime.now();
      if (now.difference(cacheTime) > _cacheValidityDuration) {
        return null;
      }

      final cachedData = sharedPreferences.getString(_profileCacheKey);
      if (cachedData == null || cachedData.isEmpty) {
        return null;
      }

      final json = jsonDecode(cachedData) as Map<String, dynamic>;
      return DriverModel.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheDriverProfile(DriverModel profile) async {
    try {
      final jsonString = jsonEncode(profile.toJson());
      await sharedPreferences.setString(_profileCacheKey, jsonString);
      await sharedPreferences.setString(_profileCacheTimeKey, DateTime.now().toIso8601String());
    } catch (e) {
      throw CacheException('Failed to cache driver profile: ${e.toString()}');
    }
  }

  @override
  Future<List<BusModel>> getCachedAssignedBuses() async {
    try {
      final cacheTime = await getLastCacheTime('assignedBuses');
      if (cacheTime == null) {
        return [];
      }

      final now = DateTime.now();
      if (now.difference(cacheTime) > _cacheValidityDuration) {
        return [];
      }

      final cachedData = sharedPreferences.getString(_assignedBusesCacheKey);
      if (cachedData == null || cachedData.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(cachedData);
      return jsonList
          .map((json) => BusModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> cacheAssignedBuses(List<BusModel> buses) async {
    try {
      final jsonList = buses.map((bus) => bus.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await sharedPreferences.setString(_assignedBusesCacheKey, jsonString);
      await sharedPreferences.setString(_assignedBusesCacheTimeKey, DateTime.now().toIso8601String());
    } catch (e) {
      throw CacheException('Failed to cache assigned buses: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await sharedPreferences.remove(_dashboardCacheKey);
      await sharedPreferences.remove(_dashboardCacheTimeKey);
      await sharedPreferences.remove(_profileCacheKey);
      await sharedPreferences.remove(_profileCacheTimeKey);
      await sharedPreferences.remove(_assignedBusesCacheKey);
      await sharedPreferences.remove(_assignedBusesCacheTimeKey);
    } catch (e) {
      throw CacheException('Failed to clear cache: ${e.toString()}');
    }
  }

  @override
  Future<DateTime?> getLastCacheTime(String cacheType) async {
    try {
      String? cacheTimeKey;
      switch (cacheType) {
        case 'dashboard':
          cacheTimeKey = _dashboardCacheTimeKey;
          break;
        case 'profile':
          cacheTimeKey = _profileCacheTimeKey;
          break;
        case 'assignedBuses':
          cacheTimeKey = _assignedBusesCacheTimeKey;
          break;
        default:
          return null;
      }
      
      final cacheTimeString = sharedPreferences.getString(cacheTimeKey);
      if (cacheTimeString == null || cacheTimeString.isEmpty) {
        return null;
      }
      return DateTime.parse(cacheTimeString);
    } catch (e) {
      return null;
    }
  }
}
