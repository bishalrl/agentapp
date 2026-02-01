import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/bus_model.dart';

abstract class BusLocalDataSource {
  Future<List<BusModel>> getCachedBuses();
  Future<void> cacheBuses(List<BusModel> buses);
  Future<void> clearCache();
  Future<DateTime?> getLastCacheTime();
}

class BusLocalDataSourceImpl implements BusLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _cacheKey = 'cached_buses';
  static const String _cacheTimeKey = 'buses_cache_time';
  static const Duration _cacheValidityDuration = Duration(hours: 1); // Cache valid for 1 hour

  BusLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<List<BusModel>> getCachedBuses() async {
    try {
      final cacheTime = await getLastCacheTime();
      if (cacheTime == null) {
        return [];
      }

      // Check if cache is still valid
      final now = DateTime.now();
      if (now.difference(cacheTime) > _cacheValidityDuration) {
        return [];
      }

      final cachedData = sharedPreferences.getString(_cacheKey);
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
  Future<void> cacheBuses(List<BusModel> buses) async {
    try {
      final jsonList = buses.map((bus) => bus.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await sharedPreferences.setString(_cacheKey, jsonString);
      await sharedPreferences.setString(_cacheTimeKey, DateTime.now().toIso8601String());
    } catch (e) {
      throw CacheException('Failed to cache buses: ${e.toString()}');
    }
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
