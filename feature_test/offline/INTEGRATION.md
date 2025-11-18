# Integration Guide

How to integrate offline support into any Flutter application.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Module Structure](#module-structure)
- [Installation](#installation)
- [Basic Integration](#basic-integration)
- [Advanced Integration](#advanced-integration)
- [Implementing Cache Service](#implementing-cache-service)
- [Implementing Request Queue](#implementing-request-queue)
- [Implementing Sync Manager](#implementing-sync-manager)
- [UI Integration](#ui-integration)
- [Best Practices](#best-practices)
- [Testing](#testing)
- [Migration Guide](#migration-guide)

---

## Prerequisites

- Flutter SDK >=3.4.1
- Basic understanding of:
  - Hive (NoSQL database)
  - Async/await patterns
  - State management (optional but recommended)

---

## Module Structure

```
lib/connectivity_offline/
├── offline_support.dart       # Main initialization
├── config/                    # Configuration classes
├── models/                    # Data models (with Hive adapters)
└── exceptions/                # Error handling

Hive Boxes (created automatically):
├── offline_cache      # Cached data
├── offline_queue      # Queued requests
└── offline_metadata   # Cache metadata
```

**Core Principle:** The module provides building blocks. You implement the services that use these blocks.

---

## Installation

### Step 1: Copy Module

```bash
# Copy offline module to your project
cp -r feature_test/offline/lib/connectivity_offline /path/to/your/project/lib/
```

### Step 2: Add Dependencies

In your `pubspec.yaml`:

```yaml
dependencies:
  # Hive for local storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0

dev_dependencies:
  # Code generation for Hive adapters
  hive_generator: ^2.0.1
  build_runner: ^2.4.9
```

### Step 3: Install

```bash
flutter pub get
```

---

## Basic Integration

### 5-Minute Quick Start

#### 1. Initialize in main.dart

```dart
import 'package:flutter/material.dart';
import 'connectivity_offline/offline_support.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize offline support
  await OfflineSupport.initialize(
    config: OfflineConfig.development(),
  );

  runApp(MyApp());
}
```

#### 2. Use Cache Anywhere

```dart
import 'package:hive/hive.dart';

class UserService {
  final _cacheBox = Hive.box('offline_cache');

  Future<User?> getUser(String userId) async {
    // Try cache first
    final cached = _cacheBox.get('user_$userId');
    if (cached != null) {
      return User.fromJson(cached);
    }

    // Fetch from network
    try {
      final user = await _fetchUserFromApi(userId);

      // Cache for later
      await _cacheBox.put('user_$userId', user.toJson());

      return user;
    } catch (e) {
      return null;  // No cache, no network
    }
  }

  Future<User> _fetchUserFromApi(String userId) async {
    // Your API call
    throw UnimplementedError();
  }
}
```

#### 3. Queue Offline Requests

```dart
class AnalyticsService {
  final _queueBox = Hive.box('offline_queue');

  Future<void> trackEvent(String event, Map<String, dynamic> properties) async {
    final request = OfflineRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      method: 'POST',
      url: 'https://api.example.com/analytics/events',
      body: {
        'event': event,
        'properties': properties,
        'timestamp': DateTime.now().toIso8601String(),
      },
      createdAt: DateTime.now(),
      priority: RequestPriority.normal,
    );

    await _queueBox.add(request);
  }
}
```

---

## Advanced Integration

### Complete Offline Service

```dart
// lib/services/offline_service.dart
import 'package:hive/hive.dart';
import '../connectivity_offline/offline_support.dart';

class OfflineService {
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  late Box _cacheBox;
  late Box _queueBox;
  late Box _metadataBox;

  Future<void> initialize() async {
    _cacheBox = Hive.box('offline_cache');
    _queueBox = Hive.box('offline_queue');
    _metadataBox = Hive.box('offline_metadata');
  }

  // === CACHE OPERATIONS ===

  /// Get data from cache with metadata tracking
  Future<T?> getFromCache<T>(
    String key, {
    T Function(dynamic)? fromJson,
  }) async {
    final data = _cacheBox.get(key);
    if (data == null) return null;

    // Update metadata
    final metadata = _metadataBox.get(key) as CacheMetadata?;
    if (metadata != null) {
      if (metadata.isExpired) {
        await removeFromCache(key);
        return null;
      }
      metadata.incrementAccessCount();
      await _metadataBox.put(key, metadata);
    }

    return fromJson != null ? fromJson(data) : data as T;
  }

  /// Save data to cache with metadata
  Future<void> saveToCache(
    String key,
    dynamic data, {
    Duration? ttl,
    String? etag,
    Map<String, String>? headers,
  }) async {
    await _cacheBox.put(key, data);

    final metadata = CacheMetadata(
      key: key,
      createdAt: DateTime.now(),
      expiresAt: ttl != null ? DateTime.now().add(ttl) : null,
      sizeInBytes: _estimateSize(data),
      accessCount: 0,
      etag: etag,
      headers: headers,
    );

    await _metadataBox.put(key, metadata);
  }

  /// Remove from cache
  Future<void> removeFromCache(String key) async {
    await _cacheBox.delete(key);
    await _metadataBox.delete(key);
  }

  /// Clear expired cache entries
  Future<void> clearExpiredCache() async {
    final keysToRemove = <String>[];

    for (var key in _metadataBox.keys) {
      final metadata = _metadataBox.get(key) as CacheMetadata?;
      if (metadata?.isExpired ?? false) {
        keysToRemove.add(key);
      }
    }

    for (var key in keysToRemove) {
      await removeFromCache(key);
    }
  }

  // === QUEUE OPERATIONS ===

  /// Add request to queue
  Future<void> queueRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    dynamic body,
    RequestPriority priority = RequestPriority.normal,
    Map<String, dynamic>? metadata,
  }) async {
    final request = OfflineRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      method: method,
      url: url,
      headers: headers,
      body: body,
      createdAt: DateTime.now(),
      priority: priority,
      metadata: metadata,
    );

    await _queueBox.add(request);
  }

  /// Get all queued requests sorted by priority
  List<OfflineRequest> getQueuedRequests() {
    final requests = _queueBox.values
        .cast<OfflineRequest>()
        .toList();

    // Sort by priority (high first)
    requests.sort((a, b) => a.priority.compareTo(b.priority));

    return requests;
  }

  /// Process queue (call this when online)
  Future<void> processQueue({
    required Future<void> Function(OfflineRequest) onRequest,
    int maxRetries = 3,
  }) async {
    final requests = getQueuedRequests();

    for (var request in requests) {
      if (!request.shouldRetry(maxRetries)) {
        // Max retries reached, remove from queue
        await request.delete();
        continue;
      }

      try {
        await onRequest(request);
        await request.delete();  // Success, remove from queue
      } catch (e) {
        request.incrementRetry(e.toString());
      }
    }
  }

  /// Clear all queued requests
  Future<void> clearQueue() async {
    await _queueBox.clear();
  }

  // === UTILITY ===

  int _estimateSize(dynamic data) {
    if (data is String) return data.length;
    if (data is Map) return data.toString().length;
    if (data is List) return data.toString().length;
    return 0;
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    int totalSize = 0;
    int expiredCount = 0;

    for (var key in _metadataBox.keys) {
      final metadata = _metadataBox.get(key) as CacheMetadata?;
      if (metadata != null) {
        totalSize += metadata.sizeInBytes;
        if (metadata.isExpired) expiredCount++;
      }
    }

    return {
      'total_entries': _cacheBox.length,
      'total_size_bytes': totalSize,
      'total_size_mb': (totalSize / (1024 * 1024)).toStringAsFixed(2),
      'expired_count': expiredCount,
      'queue_size': _queueBox.length,
    };
  }
}
```

---

## Implementing Cache Service

### HTTP Client with Caching

```dart
// lib/services/cached_http_client.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class CachedHttpClient {
  final OfflineService _offlineService;
  final http.Client _httpClient;

  CachedHttpClient({
    OfflineService? offlineService,
    http.Client? httpClient,
  })  : _offlineService = offlineService ?? OfflineService(),
        _httpClient = httpClient ?? http.Client();

  /// GET with cache support
  Future<T> get<T>(
    String url, {
    required T Function(Map<String, dynamic>) fromJson,
    CachePolicy policy = const CachePolicy.networkFirst(),
    Duration? cacheTtl,
  }) async {
    final cacheKey = 'http_get_$url';

    switch (policy.strategy) {
      case CacheStrategyType.cacheFirst:
        return await _cacheFirst(cacheKey, url, fromJson, cacheTtl);

      case CacheStrategyType.networkFirst:
        return await _networkFirst(cacheKey, url, fromJson, cacheTtl);

      case CacheStrategyType.cacheOnly:
        return await _cacheOnly(cacheKey, fromJson);

      case CacheStrategyType.networkOnly:
        return await _networkOnly(url, fromJson);

      case CacheStrategyType.staleWhileRevalidate:
        return await _staleWhileRevalidate(cacheKey, url, fromJson, cacheTtl);
    }
  }

  Future<T> _cacheFirst<T>(
    String cacheKey,
    String url,
    T Function(Map<String, dynamic>) fromJson,
    Duration? ttl,
  ) async {
    // Try cache first
    final cached = await _offlineService.getFromCache<Map<String, dynamic>>(
      cacheKey,
      fromJson: (data) => Map<String, dynamic>.from(data),
    );

    if (cached != null) {
      return fromJson(cached);
    }

    // Cache miss, fetch from network
    final response = await _httpClient.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await _offlineService.saveToCache(cacheKey, data, ttl: ttl);
      return fromJson(data);
    }

    throw Exception('Failed to load data');
  }

  Future<T> _networkFirst<T>(
    String cacheKey,
    String url,
    T Function(Map<String, dynamic>) fromJson,
    Duration? ttl,
  ) async {
    try {
      // Try network first
      final response = await _httpClient.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _offlineService.saveToCache(cacheKey, data, ttl: ttl);
        return fromJson(data);
      }
      throw Exception('HTTP ${response.statusCode}');
    } catch (e) {
      // Network failed, try cache
      final cached = await _offlineService.getFromCache<Map<String, dynamic>>(
        cacheKey,
        fromJson: (data) => Map<String, dynamic>.from(data),
      );

      if (cached != null) {
        return fromJson(cached);
      }

      rethrow;
    }
  }

  Future<T> _cacheOnly<T>(
    String cacheKey,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final cached = await _offlineService.getFromCache<Map<String, dynamic>>(
      cacheKey,
      fromJson: (data) => Map<String, dynamic>.from(data),
    );

    if (cached == null) {
      throw CacheException('No cached data for $cacheKey');
    }

    return fromJson(cached);
  }

  Future<T> _networkOnly<T>(
    String url,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final response = await _httpClient.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return fromJson(json.decode(response.body));
    }
    throw Exception('Failed to load data');
  }

  Future<T> _staleWhileRevalidate<T>(
    String cacheKey,
    String url,
    T Function(Map<String, dynamic>) fromJson,
    Duration? ttl,
  ) async {
    // Return cached immediately
    final cached = await _offlineService.getFromCache<Map<String, dynamic>>(
      cacheKey,
      fromJson: (data) => Map<String, dynamic>.from(data),
    );

    // Fetch fresh data in background (don't await)
    _fetchAndCache(cacheKey, url, ttl);

    if (cached != null) {
      return fromJson(cached);
    }

    // No cache, wait for network
    final response = await _httpClient.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await _offlineService.saveToCache(cacheKey, data, ttl: ttl);
      return fromJson(data);
    }

    throw Exception('Failed to load data');
  }

  Future<void> _fetchAndCache(String cacheKey, String url, Duration? ttl) async {
    try {
      final response = await _httpClient.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await _offlineService.saveToCache(
          cacheKey,
          json.decode(response.body),
          ttl: ttl,
        );
      }
    } catch (e) {
      // Silent fail for background fetch
    }
  }
}
```

---

## Implementing Request Queue

### Queue Processor Service

```dart
// lib/services/queue_processor.dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QueueProcessor {
  final OfflineService _offlineService;
  final Connectivity _connectivity;
  StreamSubscription? _connectivitySubscription;

  QueueProcessor({
    OfflineService? offlineService,
    Connectivity? connectivity,
  })  : _offlineService = offlineService ?? OfflineService(),
        _connectivity = connectivity ?? Connectivity();

  /// Start listening to connectivity changes
  void startAutoSync() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (result) {
        if (result != ConnectivityResult.none) {
          processQueue();
        }
      },
    );
  }

  /// Stop listening
  void dispose() {
    _connectivitySubscription?.cancel();
  }

  /// Process all queued requests
  Future<void> processQueue() async {
    print('[QueueProcessor] Processing queue...');

    await _offlineService.processQueue(
      onRequest: _executeRequest,
      maxRetries: OfflineSupport.config.retryAttempts,
    );

    print('[QueueProcessor] Queue processed');
  }

  Future<void> _executeRequest(OfflineRequest request) async {
    print('[QueueProcessor] Executing: ${request.method} ${request.url}');

    final uri = Uri.parse(request.url);
    final headers = request.headers ?? {};

    http.Response response;

    switch (request.method.toUpperCase()) {
      case 'GET':
        response = await http.get(uri, headers: headers);
        break;

      case 'POST':
        response = await http.post(
          uri,
          headers: headers,
          body: json.encode(request.body),
        );
        break;

      case 'PUT':
        response = await http.put(
          uri,
          headers: headers,
          body: json.encode(request.body),
        );
        break;

      case 'PATCH':
        response = await http.patch(
          uri,
          headers: headers,
          body: json.encode(request.body),
        );
        break;

      case 'DELETE':
        response = await http.delete(uri, headers: headers);
        break;

      default:
        throw Exception('Unsupported HTTP method: ${request.method}');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }

    print('[QueueProcessor] Success: ${request.id}');
  }
}
```

---

## Implementing Sync Manager

### Background Sync Service

```dart
// lib/services/sync_manager.dart
import 'dart:async';

class SyncManager {
  final QueueProcessor _queueProcessor;
  final OfflineService _offlineService;
  Timer? _syncTimer;

  SyncManager({
    QueueProcessor? queueProcessor,
    OfflineService? offlineService,
  })  : _queueProcessor = queueProcessor ?? QueueProcessor(),
        _offlineService = offlineService ?? OfflineService();

  /// Start periodic sync
  void startPeriodicSync(Duration interval) {
    _syncTimer?.cancel();

    _syncTimer = Timer.periodic(interval, (_) {
      sync();
    });
  }

  /// Stop periodic sync
  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Manual sync
  Future<SyncResult> sync() async {
    print('[SyncManager] Starting sync...');

    try {
      // 1. Clear expired cache
      await _offlineService.clearExpiredCache();

      // 2. Process queue
      await _queueProcessor.processQueue();

      // 3. Get stats
      final stats = _offlineService.getCacheStats();

      return SyncResult(
        success: true,
        syncedCount: stats['queue_size'] ?? 0,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return SyncResult(
        success: false,
        errorMessage: e.toString(),
        timestamp: DateTime.now(),
      );
    }
  }

  void dispose() {
    stopPeriodicSync();
  }
}
```

---

## UI Integration

### Offline Banner Widget

```dart
// lib/widgets/offline_banner.dart
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class OfflineBanner extends StatefulWidget {
  final Widget child;

  const OfflineBanner({required this.child, Key? key}) : super(key: key);

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  bool _isOnline = true;
  late StreamSubscription _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((result) {
      setState(() {
        _isOnline = result != ConnectivityResult.none;
      });
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!_isOnline)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(8),
            color: Colors.orange,
            child: Text(
              'You are offline. Some features may be limited.',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}

// Usage:
MaterialApp(
  home: OfflineBanner(
    child: HomeScreen(),
  ),
);
```

---

### Sync Status Widget

```dart
// lib/widgets/sync_status.dart
class SyncStatusWidget extends StatefulWidget {
  final SyncManager syncManager;

  const SyncStatusWidget({required this.syncManager, Key? key}) : super(key: key);

  @override
  State<SyncStatusWidget> createState() => _SyncStatusWidgetState();
}

class _SyncStatusWidgetState extends State<SyncStatusWidget> {
  bool _syncing = false;

  Future<void> _sync() async {
    setState(() => _syncing = true);
    await widget.syncManager.sync();
    setState(() => _syncing = false);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: _syncing
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(Icons.sync),
      onPressed: _syncing ? null : _sync,
      tooltip: 'Sync',
    );
  }
}
```

---

## Best Practices

### 1. Initialize Early

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize BEFORE runApp
  await OfflineSupport.initialize(
    config: OfflineConfig.production(),
  );

  runApp(MyApp());
}
```

---

### 2. Cache Strategically

```dart
// Static data: Cache first
final userAvatar = await cachedHttp.get(
  avatarUrl,
  fromJson: (json) => json,
  policy: CachePolicy.cacheFirst(ttl: Duration(days: 7)),
);

// Dynamic data: Network first
final newsFeed = await cachedHttp.get(
  '/feed',
  fromJson: (json) => Feed.fromJson(json),
  policy: CachePolicy.networkFirst(ttl: Duration(minutes: 5)),
);

// Real-time: Network only
final liveScore = await cachedHttp.get(
  '/scores/live',
  fromJson: (json) => Score.fromJson(json),
  policy: CachePolicy.networkOnly(),
);
```

---

### 3. Queue User Actions

```dart
Future<void> likePost(String postId) async {
  // Optimistic UI update
  setState(() => isLiked = true);

  // Queue request
  await offlineService.queueRequest(
    method: 'POST',
    url: '/posts/$postId/like',
    priority: RequestPriority.high,  // User action = high priority
  );
}
```

---

### 4. Handle Errors Gracefully

```dart
try {
  final data = await cachedHttp.get(...);
  showData(data);
} on CacheException {
  showMessage('No cached data available');
} on SocketException {
  showMessage('Please check your internet connection');
} catch (e) {
  showMessage('Something went wrong');
}
```

---

### 5. Monitor Cache Size

```dart
Future<void> checkCacheSize() async {
  final stats = offlineService.getCacheStats();

  final sizeMB = double.parse(stats['total_size_mb']);

  if (sizeMB > 80) {  // 80% of 100 MB limit
    // Clear expired cache
    await offlineService.clearExpiredCache();

    // Or prompt user to clear cache
    showCacheSizeWarning();
  }
}
```

---

## Testing

### Unit Tests

```dart
// test/offline_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  setUpAll(() async {
    await Hive.initFlutter();
    await OfflineSupport.initialize();
  });

  tearDownAll(() async {
    await OfflineSupport.dispose();
  });

  test('Cache stores and retrieves data', () async {
    final service = OfflineService();
    await service.initialize();

    await service.saveToCache('test_key', {'value': 123});

    final data = await service.getFromCache('test_key');

    expect(data, {'value': 123});
  });

  test('Expired cache is removed', () async {
    final service = OfflineService();
    await service.initialize();

    await service.saveToCache(
      'test_key',
      {'value': 123},
      ttl: Duration(milliseconds: 100),
    );

    await Future.delayed(Duration(milliseconds: 150));

    final data = await service.getFromCache('test_key');

    expect(data, null);
  });
}
```

---

## Migration Guide

### From Shared Preferences

```dart
// Before
final prefs = await SharedPreferences.getInstance();
final value = prefs.getString('key');

// After
final cacheBox = Hive.box('offline_cache');
final value = cacheBox.get('key');
```

### From SQLite

```dart
// Before
final db = await openDatabase('app.db');
final results = await db.query('cache', where: 'key = ?', whereArgs: [key]);

// After
final cacheBox = Hive.box('offline_cache');
final value = cacheBox.get(key);
```

---

## Integration Checklist

- [ ] Copy connectivity_offline to project
- [ ] Add Hive dependencies to pubspec.yaml
- [ ] Initialize OfflineSupport in main.dart
- [ ] Create OfflineService wrapper
- [ ] Implement CachedHttpClient (optional)
- [ ] Implement QueueProcessor (optional)
- [ ] Add connectivity_plus dependency
- [ ] Test cache read/write
- [ ] Test request queuing
- [ ] Test offline functionality
- [ ] Add offline banner UI
- [ ] Monitor cache size
- [ ] Setup periodic cleanup

---

**Ready to build offline-first apps!**
