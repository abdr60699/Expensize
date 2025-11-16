import 'offline_config.dart';

/// Policy for a specific cache entry
class CachePolicy {
  final CacheStrategyType strategy;
  final Duration? ttl;
  final bool forceRefresh;
  final bool cacheOnly;
  final bool requiresFreshData;

  const CachePolicy({
    this.strategy = CacheStrategyType.networkFirst,
    this.ttl,
    this.forceRefresh = false,
    this.cacheOnly = false,
    this.requiresFreshData = false,
  });

  const CachePolicy.networkFirst({Duration? ttl})
      : this(
          strategy: CacheStrategyType.networkFirst,
          ttl: ttl,
        );

  const CachePolicy.cacheFirst({Duration? ttl})
      : this(
          strategy: CacheStrategyType.cacheFirst,
          ttl: ttl,
        );

  const CachePolicy.cacheOnly()
      : this(
          strategy: CacheStrategyType.cacheOnly,
          cacheOnly: true,
        );

  const CachePolicy.networkOnly()
      : this(
          strategy: CacheStrategyType.networkOnly,
          forceRefresh: true,
        );

  const CachePolicy.staleWhileRevalidate({Duration? ttl})
      : this(
          strategy: CacheStrategyType.staleWhileRevalidate,
          ttl: ttl,
        );
}
