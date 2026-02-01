import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/profile_model.dart';

abstract class ProfileLocalDataSource {
  Future<ProfileModel?> getCachedProfile();
  Future<void> cacheProfile(ProfileModel profile);
  Future<void> clearCache();
  Future<DateTime?> getLastCacheTime();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _cacheKey = 'cached_profile';
  static const String _cacheTimeKey = 'profile_cache_time';
  static const Duration _cacheValidityDuration = Duration(hours: 2); // Cache valid for 2 hours

  ProfileLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<ProfileModel?> getCachedProfile() async {
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
      return ProfileModel.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheProfile(ProfileModel profile) async {
    try {
      final json = profile.toJson();
      // Add fields that aren't in toJson but are needed
      json['_id'] = profile.id;
      json['walletBalance'] = profile.walletBalance;
      json['avatarUrl'] = profile.avatarUrl;
      json['isVerified'] = profile.isVerified;
      
      final jsonString = jsonEncode(json);
      await sharedPreferences.setString(_cacheKey, jsonString);
      await sharedPreferences.setString(_cacheTimeKey, DateTime.now().toIso8601String());
    } catch (e) {
      throw CacheException('Failed to cache profile: ${e.toString()}');
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
