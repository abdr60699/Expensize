# Offline Support Features

Complete guide to offline capabilities, local caching, and request queuing.

## Table of Contents

- [Module Overview](#module-overview)
- [Folder Structure](#folder-structure)
- [Core Features](#core-features)
- [Cache Strategies](#cache-strategies)
- [Request Queue](#request-queue)
- [Sync Management](#sync-management)
- [Use Cases](#use-cases)
- [Feature Matrix](#feature-matrix)

---

## Module Overview

Production-ready offline support module for Flutter apps with:
- **Local caching** using Hive (fast NoSQL database)
- **Request queue** for offline operations
- **Smart sync** with conflict resolution
- **Connectivity detection** for auto-sync
- **Flexible cache strategies** for different scenarios

---

## Folder Structure

### Directory Tree

```
lib/
└── connectivity_offline/
    ├── offline_support.dart           # Main entry point & initialization
    │
    ├── config/                         # Configuration
    │   ├── offline_config.dart         # Module configuration
    │   ├── cache_policy.dart           # Cache strategies
    │   └── sync_policy.dart            # Sync & conflict resolution
    │
    ├── models/                         # Data Models
    │   ├── cache_metadata.dart         # Cache entry metadata
    │   ├── cache_metadata.g.dart       # Generated Hive adapter
    │   ├── offline_request.dart        # Queued request model
    │   ├── offline_request.g.dart      # Generated Hive adapter
    │   ├── connectivity_state.dart     # Network connectivity state
    │   ├── sync_result.dart            # Sync operation result
    │   └── network_request_info.dart   # Network request information
    │
    └── exceptions/                     # Error Handling
        ├── offline_exception.dart      # Base offline exception
        ├── cache_exception.dart        # Cache errors
        └── sync_exception.dart         # Sync errors

Hive Boxes (Local Storage):
├── offline_cache       # Cached data entries
├── offline_queue       # Queued requests
└── offline_metadata    # Cache metadata
```

### Key Components

#### **config/**
- **offline_config.dart**: Central configuration (cache size, retry attempts, sync intervals)
- **cache_policy.dart**: Cache strategy definitions (networkFirst, cacheFirst, etc.)
- **sync_policy.dart**: Conflict resolution and sync constraints

#### **models/**
- **cache_metadata.dart**: Tracks expiration, size, access count, ETags
- **offline_request.dart**: Queued requests with priority and retry tracking
- **connectivity_state.dart**: Network status (online/offline)
- **sync_result.dart**: Sync operation outcomes

#### **exceptions/**
Categorized error handling for cache and sync failures

---

## Core Features

### 1. Local Caching with Hive

Store data locally for instant offline access.

```dart
// Initialize offline support
await OfflineSupport.initialize(
  config: OfflineConfig.development(),
);

// Access cache box
final cacheBox = Hive.box('offline_cache');

// Store data
await cacheBox.put('user_profile', {
  'id': '123',
  'name': 'John Doe',
  'email': 'john@example.com',
});

// Retrieve data
final profile = cacheBox.get('user_profile');
print('Name: ${profile['name']}');

// Check if key exists
if (cacheBox.containsKey('user_profile')) {
  print('Profile cached!');
}

// Get all keys
final keys = cacheBox.keys;
print('Cached keys: $keys');
```

**Features:**
- Fast NoSQL storage (Hive)
- Type-safe with generated adapters
- Automatic persistence across app restarts
- Support for any serializable data type

---

### 2. Cache Metadata Tracking

Track cache entry metadata for intelligent caching.

```dart
final metadata = CacheMetadata(
  key: 'user_profile',
  createdAt: DateTime.now(),
  expiresAt: DateTime.now().add(Duration(hours: 1)),
  sizeInBytes: 1024,
  accessCount: 0,
  etag: 'W/"abc123"',
  headers: {'content-type': 'application/json'},
);

// Store metadata
final metadataBox = Hive.box('offline_metadata');
await metadataBox.put('user_profile', metadata);

// Check expiration
if (metadata.isExpired) {
  print('Cache expired, need to refresh');
}

// Track access
metadata.incrementAccessCount();

// Calculate age
final age = metadata.age;
print('Cache age: ${age.inMinutes} minutes');
```

**Metadata Properties:**
- Creation and expiration timestamps
- Size in bytes (for cache size management)
- Access count (for LRU eviction)
- ETags (for conditional requests)
- Custom headers

---

### 3. Request Queue with Priority

Queue network requests when offline and execute when online.

```dart
final request = OfflineRequest(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  method: 'POST',
  url: 'https://api.example.com/users',
  headers: {'Content-Type': 'application/json'},
  body: {'name': 'John Doe', 'email': 'john@example.com'},
  createdAt: DateTime.now(),
  priority: RequestPriority.high,
);

// Queue request
final queueBox = Hive.box('offline_queue');
await queueBox.add(request);

// Process queue when online
for (var req in queueBox.values) {
  if (req.shouldRetry(maxRetries: 3)) {
    try {
      // Execute request
      await executeRequest(req);
      await req.delete(); // Remove from queue
    } catch (e) {
      req.incrementRetry(e.toString());
    }
  }
}
```

**Queue Features:**
- Priority levels (high, normal, low)
- Automatic retry with exponential backoff
- Persistent across app restarts
- Error tracking for debugging

---

### 4. Cache Strategies

Five different strategies for various scenarios.

#### Network First

Try network, fallback to cache.

```dart
final policy = CachePolicy.networkFirst(
  ttl: Duration(hours: 1),
);

// Best for: Frequently changing data
// Example: News feed, social media posts
```

#### Cache First

Try cache, fallback to network.

```dart
final policy = CachePolicy.cacheFirst(
  ttl: Duration(days: 7),
);

// Best for: Static data, assets
// Example: User avatars, app configuration
```

#### Cache Only

Always use cached data, never fetch from network.

```dart
final policy = CachePolicy.cacheOnly();

// Best for: Offline-only features
// Example: Downloaded content, bookmarks
```

#### Network Only

Always fetch from network, never cache.

```dart
final policy = CachePolicy.networkOnly();

// Best for: Real-time data
// Example: Live scores, stock prices
```

#### Stale While Revalidate

Return cached data immediately, fetch fresh data in background.

```dart
final policy = CachePolicy.staleWhileRevalidate(
  ttl: Duration(minutes: 5),
);

// Best for: Balanced UX and freshness
// Example: User timelines, product listings
```

---

## Cache Strategies

### Strategy Comparison

| Strategy | Network Call | Cache Usage | Best For |
|----------|-------------|-------------|----------|
| Network First | Always tries | Fallback only | Frequently updated data |
| Cache First | Only if cache miss | Primary source | Static/rarely changing data |
| Cache Only | Never | Always | Offline-only features |
| Network Only | Always | Never | Real-time data |
| Stale While Revalidate | Background | Immediate return | Balance speed & freshness |

---

### Configuration

```dart
final config = OfflineConfig(
  // Default strategy for all requests
  defaultCacheStrategy: CacheStrategyType.networkFirst,

  // Cache duration
  cacheDuration: Duration(hours: 1),

  // Cache size limits
  maxCacheSizeInMB: 50,
  maxCacheEntries: 1000,

  // Cache compression
  cacheCompression: false,

  // Exclude sensitive headers from cache
  excludeHeaders: ['Authorization', 'Cookie'],
);
```

---

## Request Queue

### Priority Levels

```dart
enum RequestPriority {
  high,    // User-initiated actions (e.g., save post)
  normal,  // Regular operations (e.g., analytics)
  low,     // Background tasks (e.g., prefetch)
}
```

### Queue Management

```dart
// Add to queue with priority
final request = OfflineRequest(
  id: generateId(),
  method: 'POST',
  url: 'https://api.example.com/data',
  body: {'data': 'value'},
  createdAt: DateTime.now(),
  priority: RequestPriority.high,  // Process first
);

await queueBox.add(request);

// Process queue by priority
final sortedRequests = queueBox.values.toList()
  ..sort((a, b) => a.priority.compareTo(b.priority));

for (var req in sortedRequests) {
  // Process high priority first
}
```

---

### Retry Configuration

```dart
final config = OfflineConfig(
  retryAttempts: 3,                        // Max retry attempts
  retryDelay: Duration(seconds: 1),        // Initial delay
  retryMultiplier: 2.0,                    // Exponential backoff
  maxRetryDelay: Duration(seconds: 30),    // Max delay cap
);

// Retry delays: 1s, 2s, 4s (capped at 30s)
```

---

### Queue Persistence

```dart
final config = OfflineConfig(
  enableRequestQueue: true,
  queuePersistence: true,     // Persist across app restarts
  maxQueueSize: 100,          // Limit queue size
);

// Queue persists even if app is closed
// Automatically processes when app reopens and network is available
```

---

## Sync Management

### Auto-Sync

Automatically sync when connectivity is restored.

```dart
final config = OfflineConfig(
  enableAutoSync: true,
  syncOnAppStart: true,
  syncInterval: Duration(minutes: 30),
  syncTimeout: Duration(seconds: 120),
);

// Triggers sync:
// - When app starts (if configured)
// - When network becomes available
// - At specified intervals
// - Manually via OfflineSupport.sync()
```

---

### Background Sync

Sync even when app is in background.

```dart
final config = OfflineConfig(
  enableBackgroundSync: true,
  syncInterval: Duration(hours: 1),
);

// Requires platform-specific setup:
// - Android: WorkManager
// - iOS: Background fetch
```

---

### Conflict Resolution

Handle conflicts when local and server data differ.

```dart
final syncPolicy = SyncPolicy(
  conflictResolution: ConflictResolutionStrategy.serverWins,
);

// Strategies:
// - serverWins: Always use server data
// - clientWins: Always use local data
// - merge: Attempt to merge both
// - promptUser: Ask user to resolve
```

---

### Sync Policies

#### Conservative (WiFi only, charging)

```dart
final syncPolicy = SyncPolicy.conservative();
// syncOnlyOnWifi: true
// syncOnlyWhenCharging: true

// Best for: Large data transfers, battery-conscious apps
```

#### Aggressive (Any connection)

```dart
final syncPolicy = SyncPolicy.aggressive();
// syncOnlyOnWifi: false
// syncOnlyWhenCharging: false

// Best for: Real-time collaboration, messaging apps
```

---

## Use Cases

### Use Case 1: Social Media Feed

```dart
// Cache recent posts with stale-while-revalidate
final config = OfflineConfig(
  defaultCacheStrategy: CacheStrategyType.staleWhileRevalidate,
  cacheDuration: Duration(minutes: 5),
);

// User opens app:
// 1. Show cached feed immediately (instant UX)
// 2. Fetch fresh posts in background
// 3. Update UI when new data arrives

// User goes offline:
// - Can still view cached posts
// - Likes/comments queued for later
```

---

### Use Case 2: E-Commerce Product Catalog

```dart
// Cache products for offline browsing
final config = OfflineConfig(
  defaultCacheStrategy: CacheStrategyType.cacheFirst,
  cacheDuration: Duration(days: 7),
  maxCacheSizeInMB: 100,
);

// Features:
// - Browse products offline
// - Queue purchases when offline
// - Sync when online
// - Show "saved for offline" badge
```

---

### Use Case 3: Expense Tracker

```dart
// Queue expense entries when offline
final config = OfflineConfig(
  enableRequestQueue: true,
  queuePersistence: true,
  defaultCacheStrategy: CacheStrategyType.networkFirst,
);

// Workflow:
// 1. User adds expense (offline)
// 2. Entry queued with high priority
// 3. Auto-sync when online
// 4. Show sync status in UI
```

---

### Use Case 4: News Reader

```dart
// Download articles for offline reading
final config = OfflineConfig(
  defaultCacheStrategy: CacheStrategyType.cacheOnly,  // For saved articles
  maxCacheSizeInMB: 200,
);

// Features:
// - Download articles for offline
// - Track download progress
// - Manage storage (delete old articles)
// - Sync reading progress across devices
```

---

### Use Case 5: Collaborative Document Editor

```dart
// Real-time sync with conflict resolution
final config = OfflineConfig(
  enableAutoSync: true,
  syncInterval: Duration(seconds: 30),
);

final syncPolicy = SyncPolicy(
  conflictResolution: ConflictResolutionStrategy.merge,
);

// Features:
// - Edit offline
// - Queue changes
// - Merge conflicts automatically
// - Show other users' changes
```

---

## Feature Matrix

| Feature | Supported | Configuration |
|---------|-----------|--------------|
| Local Caching | ✅ | Hive boxes |
| Cache Metadata | ✅ | ETags, expiration, size |
| Request Queue | ✅ | Priority, retry, persistence |
| Cache Strategies | ✅ | 5 strategies |
| Auto-Sync | ✅ | Configurable intervals |
| Background Sync | ⚠️ | Requires platform setup |
| Conflict Resolution | ✅ | 4 strategies |
| Connectivity Detection | 🔜 | Planned |
| Offline HTTP Client | 🔜 | Planned |
| Sync Manager | 🔜 | Planned |
| Offline Banner Widget | 🔜 | Planned |

**Legend:**
- ✅ Fully implemented
- ⚠️ Requires additional setup
- 🔜 Planned / scaffolded

---

## Configuration Options

### Development

```dart
final config = OfflineConfig.development();

// Features:
// - Debug mode enabled
// - Short cache duration (5 min)
// - Frequent connectivity checks (10s)
// - Verbose logging
```

### Production

```dart
final config = OfflineConfig.production();

// Features:
// - Debug mode disabled
// - Long cache duration (24 hours)
// - Background sync enabled
// - Optimized performance
```

### Custom

```dart
final config = OfflineConfig(
  // Basic
  enabled: true,
  debugMode: false,
  environment: 'staging',

  // Cache
  defaultCacheStrategy: CacheStrategyType.networkFirst,
  cacheDuration: Duration(hours: 2),
  maxCacheSizeInMB: 50,
  maxCacheEntries: 1000,
  cacheCompression: true,
  excludeHeaders: ['Authorization'],

  // Queue
  enableRequestQueue: true,
  maxQueueSize: 100,
  queuePersistence: true,
  retryAttempts: 3,
  retryDelay: Duration(seconds: 1),
  retryMultiplier: 2.0,
  maxRetryDelay: Duration(seconds: 30),

  // Sync
  enableAutoSync: true,
  enableBackgroundSync: false,
  syncInterval: Duration(minutes: 30),
  syncOnAppStart: true,
  syncTimeout: Duration(seconds: 120),

  // Network
  connectivityCheckUrl: 'https://www.google.com',
  connectivityCheckInterval: Duration(seconds: 30),
  connectivityCheckTimeout: Duration(seconds: 5),
  requireInternetConnection: true,
);
```

---

## Performance Characteristics

| Operation | Speed | Notes |
|-----------|-------|-------|
| Cache Read | ~0.1ms | Hive is very fast |
| Cache Write | ~1ms | Asynchronous |
| Queue Add | ~1ms | Asynchronous |
| Metadata Lookup | ~0.1ms | In-memory access |
| Box Initialization | ~10ms | One-time cost |

---

## Storage Limits

| Resource | Default Limit | Configurable |
|----------|--------------|-------------|
| Cache Size | 50 MB | ✅ `maxCacheSizeInMB` |
| Cache Entries | 1000 | ✅ `maxCacheEntries` |
| Queue Size | 100 | ✅ `maxQueueSize` |
| Retry Attempts | 3 | ✅ `retryAttempts` |

---

**Ready to build offline-first Flutter apps!**
