import 'package:flutter_bloc/flutter_bloc.dart';
import '../cache/cache_manager.dart';

/// Mixin for optimized BLoC behavior:
/// - Prevents duplicate events
/// - Granular loading states
/// - Cache-first data loading
/// - Optimistic updates
mixin OptimizedBlocMixin<Event, State> on Bloc<Event, State> {
  // Track ongoing events to prevent duplicates
  final Set<String> _processingEvents = {};
  
  /// Execute event handler with deduplication
  Future<void> executeWithDeduplication(
    Event event,
    String eventKey,
    Future<void> Function() handler,
  ) async {
    // Prevent duplicate events
    if (_processingEvents.contains(eventKey)) {
      print('⚠️ Duplicate event ignored: $eventKey');
      return;
    }
    
    _processingEvents.add(eventKey);
    try {
      await handler();
    } finally {
      _processingEvents.remove(eventKey);
    }
  }
  
  /// Load data with cache-first strategy
  Future<T?> loadWithCache<T>({
    required String cacheKey,
    required Future<T> Function() fetchRemote,
    Duration? ttl,
    bool forceRefresh = false,
  }) async {
    // Try cache first (unless force refresh)
    if (!forceRefresh) {
      final cached = CacheManager.get<T>(cacheKey, ttl: ttl);
      if (cached != null) {
        print('✅ Cache hit: $cacheKey');
        return cached;
      }
    }
    
    // Fetch from remote
    try {
      final data = await fetchRemote();
      
      // Cache the result
      await CacheManager.set(cacheKey, data, ttl: ttl);
      
      return data;
    } catch (e) {
      // On error, try to return stale cache
      final staleCache = CacheManager.get<T>(cacheKey);
      if (staleCache != null) {
        print('⚠️ Using stale cache due to error: $cacheKey');
        return staleCache;
      }
      rethrow;
    }
  }
  
  /// Generate event key from event
  String getEventKey(Event event) {
    return event.toString();
  }
}
