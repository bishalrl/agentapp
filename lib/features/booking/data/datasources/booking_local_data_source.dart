import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/booking_model.dart';

abstract class BookingLocalDataSource {
  Future<List<BookingModel>> getCachedBookings();
  Future<void> cacheBookings(List<BookingModel> bookings);
  Future<void> clearCache();
  Future<DateTime?> getLastCacheTime();
}

class BookingLocalDataSourceImpl implements BookingLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _cacheKey = 'cached_bookings';
  static const String _cacheTimeKey = 'bookings_cache_time';
  static const Duration _cacheValidityDuration = Duration(hours: 1); // Cache valid for 1 hour

  BookingLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<List<BookingModel>> getCachedBookings() async {
    try {
      final cacheTime = await getLastCacheTime();
      if (cacheTime == null) {
        return [];
      }

      // Check if cache is still valid
      final now = DateTime.now();
      if (now.difference(cacheTime) > _cacheValidityDuration) {
        // Cache expired, return empty list
        return [];
      }

      final cachedData = sharedPreferences.getString(_cacheKey);
      if (cachedData == null || cachedData.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(cachedData);
      return jsonList
          .map((json) => BookingModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException('Failed to get cached bookings: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheBookings(List<BookingModel> bookings) async {
    try {
      final jsonList = bookings.map((booking) => booking.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await sharedPreferences.setString(_cacheKey, jsonString);
      await sharedPreferences.setString(_cacheTimeKey, DateTime.now().toIso8601String());
    } catch (e) {
      throw CacheException('Failed to cache bookings: ${e.toString()}');
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
