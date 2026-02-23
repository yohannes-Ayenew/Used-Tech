// lib/core/network/cache_manager.dart

class CacheManager {
  static final Map<String, CacheEntry> _memoryCache = {};
  static final Map<String, DateTime> _staleCache = {};

  static Future<T> getOrFetch<T>(
    String key,
    Future<T> Function() fetcher, {
    Duration ttl = const Duration(minutes: 5),
    bool forceRefresh = false,
  }) async {
    // Check memory cache first
    if (!forceRefresh && _memoryCache.containsKey(key)) {
      final entry = _memoryCache[key]!;
      if (!entry.isExpired) {
        return entry.data as T;
      }
    }

    // Fetch fresh data
    final data = await fetcher();
    _memoryCache[key] = CacheEntry(data, DateTime.now().add(ttl));
    return data;
  }

  static void set(
    String key,
    dynamic data, {
    Duration ttl = const Duration(minutes: 5),
  }) {
    _memoryCache[key] = CacheEntry(data, DateTime.now().add(ttl));
  }

  static dynamic get(String key) {
    final entry = _memoryCache[key];
    if (entry != null && !entry.isExpired) {
      return entry.data;
    }
    return null;
  }

  static void invalidate(String key) {
    _memoryCache.remove(key);
    _staleCache.remove(key);
  }

  static void invalidateAll() {
    _memoryCache.clear();
    _staleCache.clear();
  }

  static void markStale(String key) {
    _staleCache[key] = DateTime.now();
  }

  static bool isStale(String key) {
    final staleTime = _staleCache[key];
    if (staleTime == null) return false;
    return DateTime.now().difference(staleTime) > const Duration(minutes: 1);
  }
}

class CacheEntry {
  final dynamic data;
  final DateTime expiry;

  CacheEntry(this.data, this.expiry);

  bool get isExpired => DateTime.now().isAfter(expiry);
}
