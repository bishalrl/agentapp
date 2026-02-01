import 'dart:convert';
import '../errors/exceptions.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Centralized cache manager using Hive for fast local storage
/// Provides TTL-based caching, cache invalidation, and smart refresh
class CacheManager {
  static const String _boxName = 'app_cache';
  static Box? _box;
  
  /// Initialize cache (call this in main.dart)
  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }
  
  /// Get cached data with TTL check
  static T? get<T>(String key, {Duration? ttl}) {
    if (_box == null) return null;
    
    try {
      final cached = _box!.get(key);
      if (cached == null) return null;
      
      final data = jsonDecode(cached as String) as Map<String, dynamic>;
      final timestamp = DateTime.parse(data['timestamp'] as String);
      final value = data['value'];
      
      // Check TTL
      if (ttl != null && DateTime.now().difference(timestamp) > ttl) {
        _box!.delete(key);
        return null;
      }
      
      return _deserialize<T>(value);
    } catch (e) {
      print('⚠️ Cache get error for key $key: $e');
      return null;
    }
  }
  
  /// Set cached data with timestamp
  static Future<void> set<T>(String key, T value, {Duration? ttl}) async {
    if (_box == null) return;
    
    try {
      final data = {
        'timestamp': DateTime.now().toIso8601String(),
        'value': _serialize(value),
        'ttl': ttl?.inSeconds,
      };
      
      await _box!.put(key, jsonEncode(data));
    } catch (e) {
      print('⚠️ Cache set error for key $key: $e');
      throw CacheException('Failed to cache data: ${e.toString()}');
    }
  }
  
  /// Check if cache is valid (exists and not expired)
  static bool isValid(String key, {Duration? ttl}) {
    if (_box == null) return false;
    
    try {
      final cached = _box!.get(key);
      if (cached == null) return false;
      
      final data = jsonDecode(cached as String) as Map<String, dynamic>;
      final timestamp = DateTime.parse(data['timestamp'] as String);
      
      if (ttl != null && DateTime.now().difference(timestamp) > ttl) {
        return false;
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Get cache age
  static Duration? getAge(String key) {
    if (_box == null) return null;
    
    try {
      final cached = _box!.get(key);
      if (cached == null) return null;
      
      final data = jsonDecode(cached as String) as Map<String, dynamic>;
      final timestamp = DateTime.parse(data['timestamp'] as String);
      return DateTime.now().difference(timestamp);
    } catch (e) {
      return null;
    }
  }
  
  /// Invalidate cache for a key
  static Future<void> invalidate(String key) async {
    if (_box == null) return;
    await _box!.delete(key);
  }
  
  /// Invalidate cache matching pattern
  static Future<void> invalidatePattern(String pattern) async {
    if (_box == null) return;
    
    final keys = _box!.keys.where((key) => key.toString().contains(pattern));
    for (final key in keys) {
      await _box!.delete(key);
    }
  }
  
  /// Clear all cache
  static Future<void> clear() async {
    if (_box == null) return;
    await _box!.clear();
  }
  
  /// Preload cache (useful for app startup)
  static Future<void> preload(List<String> keys) async {
    // Preload can be used to warm cache on app start
    // Implementation depends on your needs
  }
  
  static dynamic _serialize<T>(T value) {
    if (value is Map || value is List) {
      return value;
    }
    if (value is String || value is num || value is bool) {
      return value;
    }
    // For complex objects, convert to JSON-serializable format
    return value.toString();
  }
  
  static T? _deserialize<T>(dynamic value) {
    if (value is T) return value;
    return null;
  }
}

/// Cache keys constants
class CacheKeys {
  static const String dashboard = 'dashboard';
  static const String buses = 'buses';
  static const String bookings = 'bookings';
  static const String profile = 'profile';
  
  static String bus(String id) => 'bus_$id';
  static String booking(String id) => 'booking_$id';
  static String busesByRoute(String route) => 'buses_route_$route';
  static String bookingsByDate(String date) => 'bookings_date_$date';
}

/// Cache TTL constants
class CacheTTL {
  static const Duration dashboard = Duration(minutes: 5);
  static const Duration buses = Duration(minutes: 10);
  static const Duration bookings = Duration(minutes: 5);
  static const Duration profile = Duration(hours: 1);
  static const Duration busDetail = Duration(minutes: 15);
  static const Duration bookingDetail = Duration(minutes: 15);
}
