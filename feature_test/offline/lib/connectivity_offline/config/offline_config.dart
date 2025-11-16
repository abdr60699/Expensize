/// Cache strategy enum
enum CacheStrategyType {
  networkFirst,
  cacheFirst,
  cacheOnly,
  networkOnly,
  staleWhileRevalidate,
}

/// Configuration for the offline support module
class OfflineConfig {
  // Basic configuration
  final bool enabled;
  final bool debugMode;
  final String environment;

  // Cache configuration
  final CacheStrategyType defaultCacheStrategy;
  final Duration cacheDuration;
  final int maxCacheSizeInMB;
  final int maxCacheEntries;
  final bool cacheCompression;
  final List<String> excludeHeaders;

  // Queue configuration
  final bool enableRequestQueue;
  final int maxQueueSize;
  final bool queuePersistence;
  final int retryAttempts;
  final Duration retryDelay;
  final double retryMultiplier;
  final Duration maxRetryDelay;

  // Sync configuration
  final bool enableAutoSync;
  final bool enableBackgroundSync;
  final Duration syncInterval;
  final bool syncOnAppStart;
  final Duration syncTimeout;

  // Network configuration
  final String connectivityCheckUrl;
  final Duration connectivityCheckInterval;
  final Duration connectivityCheckTimeout;
  final bool requireInternetConnection;

  const OfflineConfig({
    this.enabled = true,
    this.debugMode = false,
    this.environment = 'production',
    // Cache
    this.defaultCacheStrategy = CacheStrategyType.networkFirst,
    this.cacheDuration = const Duration(hours: 1),
    this.maxCacheSizeInMB = 50,
    this.maxCacheEntries = 1000,
    this.cacheCompression = false,
    this.excludeHeaders = const ['Authorization', 'Cookie'],
    // Queue
    this.enableRequestQueue = true,
    this.maxQueueSize = 100,
    this.queuePersistence = true,
    this.retryAttempts = 3,
    this.retryDelay = const Duration(seconds: 1),
    this.retryMultiplier = 2.0,
    this.maxRetryDelay = const Duration(seconds: 30),
    // Sync
    this.enableAutoSync = true,
    this.enableBackgroundSync = false,
    this.syncInterval = const Duration(minutes: 30),
    this.syncOnAppStart = true,
    this.syncTimeout = const Duration(seconds: 120),
    // Network
    this.connectivityCheckUrl = 'https://www.google.com',
    this.connectivityCheckInterval = const Duration(seconds: 30),
    this.connectivityCheckTimeout = const Duration(seconds: 5),
    this.requireInternetConnection = true,
  });

  int get maxCacheSizeInBytes => maxCacheSizeInMB * 1024 * 1024;

  OfflineConfig copyWith({
    bool? enabled,
    bool? debugMode,
    String? environment,
    CacheStrategyType? defaultCacheStrategy,
    Duration? cacheDuration,
    int? maxCacheSizeInMB,
    int? maxCacheEntries,
    bool? cacheCompression,
    List<String>? excludeHeaders,
    bool? enableRequestQueue,
    int? maxQueueSize,
    bool? queuePersistence,
    int? retryAttempts,
    Duration? retryDelay,
    double? retryMultiplier,
    Duration? maxRetryDelay,
    bool? enableAutoSync,
    bool? enableBackgroundSync,
    Duration? syncInterval,
    bool? syncOnAppStart,
    Duration? syncTimeout,
    String? connectivityCheckUrl,
    Duration? connectivityCheckInterval,
    Duration? connectivityCheckTimeout,
    bool? requireInternetConnection,
  }) {
    return OfflineConfig(
      enabled: enabled ?? this.enabled,
      debugMode: debugMode ?? this.debugMode,
      environment: environment ?? this.environment,
      defaultCacheStrategy: defaultCacheStrategy ?? this.defaultCacheStrategy,
      cacheDuration: cacheDuration ?? this.cacheDuration,
      maxCacheSizeInMB: maxCacheSizeInMB ?? this.maxCacheSizeInMB,
      maxCacheEntries: maxCacheEntries ?? this.maxCacheEntries,
      cacheCompression: cacheCompression ?? this.cacheCompression,
      excludeHeaders: excludeHeaders ?? this.excludeHeaders,
      enableRequestQueue: enableRequestQueue ?? this.enableRequestQueue,
      maxQueueSize: maxQueueSize ?? this.maxQueueSize,
      queuePersistence: queuePersistence ?? this.queuePersistence,
      retryAttempts: retryAttempts ?? this.retryAttempts,
      retryDelay: retryDelay ?? this.retryDelay,
      retryMultiplier: retryMultiplier ?? this.retryMultiplier,
      maxRetryDelay: maxRetryDelay ?? this.maxRetryDelay,
      enableAutoSync: enableAutoSync ?? this.enableAutoSync,
      enableBackgroundSync: enableBackgroundSync ?? this.enableBackgroundSync,
      syncInterval: syncInterval ?? this.syncInterval,
      syncOnAppStart: syncOnAppStart ?? this.syncOnAppStart,
      syncTimeout: syncTimeout ?? this.syncTimeout,
      connectivityCheckUrl: connectivityCheckUrl ?? this.connectivityCheckUrl,
      connectivityCheckInterval:
          connectivityCheckInterval ?? this.connectivityCheckInterval,
      connectivityCheckTimeout:
          connectivityCheckTimeout ?? this.connectivityCheckTimeout,
      requireInternetConnection:
          requireInternetConnection ?? this.requireInternetConnection,
    );
  }

  /// Development environment configuration
  static OfflineConfig development() {
    return const OfflineConfig(
      debugMode: true,
      environment: 'development',
      cacheDuration: Duration(minutes: 5),
      connectivityCheckInterval: Duration(seconds: 10),
    );
  }

  /// Production environment configuration
  static OfflineConfig production() {
    return const OfflineConfig(
      debugMode: false,
      environment: 'production',
      cacheDuration: Duration(hours: 24),
      enableBackgroundSync: true,
    );
  }
}
