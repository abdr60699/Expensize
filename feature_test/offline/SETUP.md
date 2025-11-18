# Setup Guide

Complete setup instructions for offline support from scratch.

## Table of Contents

- [Module Structure](#module-structure)
- [Dependencies](#dependencies)
- [Installation](#installation)
- [Hive Setup](#hive-setup)
- [Module Initialization](#module-initialization)
- [Configuration](#configuration)
- [Connectivity Setup](#connectivity-setup)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)
- [Platform-Specific Setup](#platform-specific-setup)

---

## Module Structure

### Directory Organization

```
lib/
└── connectivity_offline/           # Offline Support Module
    │
    ├── offline_support.dart        # 🔧 Main Entry Point
    │   - Module initialization
    │   - Hive adapter registration
    │   - Box management
    │
    ├── config/                     # ⚙️ Configuration
    │   ├── offline_config.dart     # Module configuration
    │   │   - Cache settings
    │   │   - Queue settings
    │   │   - Sync settings
    │   │   - Network settings
    │   │
    │   ├── cache_policy.dart       # Cache strategies
    │   │   - networkFirst
    │   │   - cacheFirst
    │   │   - cacheOnly
    │   │   - networkOnly
    │   │   - staleWhileRevalidate
    │   │
    │   └── sync_policy.dart        # Sync policies
    │       - Conflict resolution
    │       - WiFi/charging constraints
    │
    ├── models/                     # 📦 Data Models
    │   ├── cache_metadata.dart     # Cache entry metadata
    │   ├── cache_metadata.g.dart   # Generated Hive adapter
    │   ├── offline_request.dart    # Queued request
    │   ├── offline_request.g.dart  # Generated Hive adapter
    │   ├── connectivity_state.dart # Network state
    │   ├── sync_result.dart        # Sync result
    │   └── network_request_info.dart # Request info
    │
    └── exceptions/                 # ⚠️ Error Handling
        ├── offline_exception.dart  # Base exception
        ├── cache_exception.dart    # Cache errors
        └── sync_exception.dart     # Sync errors

Hive Boxes (Created Automatically):
├── offline_cache      # Stores cached data
├── offline_queue      # Stores queued requests
└── offline_metadata   # Stores cache metadata
```

### Component Responsibilities

**offline_support.dart**
- Initialize Hive
- Register type adapters
- Open boxes
- Provide singleton access
- Clear all data

**config/**
- Define cache strategies
- Configure retry logic
- Set sync policies
- Manage conflict resolution

**models/**
- Define data structures
- Hive type adapters
- Model validation

**exceptions/**
- Categorized error types
- Error messages
- Stack trace preservation

---

## Dependencies

### pubspec.yaml

Add these dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Core - Local storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # Optional - Connectivity detection
  connectivity_plus: ^6.0.5

  # Optional - HTTP client (for integration)
  http: ^1.2.2

dev_dependencies:
  # Code generation for Hive
  hive_generator: ^2.0.1
  build_runner: ^2.4.9
```

### Install Dependencies

```bash
flutter pub get
```

---

## Installation

### Step 1: Copy Module Files

```bash
# Copy the connectivity_offline directory to your project
cp -r feature_test/offline/lib/connectivity_offline /path/to/your/project/lib/
```

Your project structure should look like:

```
your_project/
├── lib/
│   ├── main.dart
│   ├── connectivity_offline/    ← Module files here
│   └── ... your other files
└── pubspec.yaml
```

---

### Step 2: Verify Files

Ensure you have all these files:

```bash
lib/connectivity_offline/
├── offline_support.dart
├── config/
│   ├── offline_config.dart
│   ├── cache_policy.dart
│   └── sync_policy.dart
├── models/
│   ├── cache_metadata.dart
│   ├── cache_metadata.g.dart     ← Generated file
│   ├── offline_request.dart
│   ├── offline_request.g.dart    ← Generated file
│   ├── connectivity_state.dart
│   ├── sync_result.dart
│   └── network_request_info.dart
└── exceptions/
    ├── offline_exception.dart
    ├── cache_exception.dart
    └── sync_exception.dart
```

---

### Step 3: Generate Hive Adapters (If Missing)

If `.g.dart` files are missing, generate them:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This generates:
- `cache_metadata.g.dart`
- `offline_request.g.dart`

---

## Hive Setup

### Initialize Hive

In your `main.dart`:

```dart
import 'package:flutter/material.dart';
import 'connectivity_offline/offline_support.dart';

Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize offline support
  await OfflineSupport.initialize(
    config: OfflineConfig.development(),
  );

  runApp(MyApp());
}
```

---

### What Happens During Initialization?

```dart
OfflineSupport.initialize() performs:

1. Hive.initFlutter()           // Initialize Hive
2. Register type adapters        // CacheMetadata, OfflineRequest
3. Open boxes:
   - offline_cache               // For cached data
   - offline_queue               // For queued requests
   - offline_metadata            // For cache metadata
4. Store configuration           // Make config globally accessible
```

---

### Manual Initialization (Advanced)

If you need custom initialization:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Step 1: Initialize Hive
  await Hive.initFlutter();

  // Step 2: Register adapters
  await OfflineSupport.registerHiveAdapters();

  // Step 3: Open boxes
  await Hive.openBox('offline_cache');
  await Hive.openBox('offline_queue');
  await Hive.openBox('offline_metadata');

  // Step 4: Set config
  await OfflineSupport.initialize(
    config: OfflineConfig.production(),
  );

  runApp(MyApp());
}
```

---

## Module Initialization

### Basic Initialization

```dart
// Simplest setup
await OfflineSupport.initialize();
```

Uses default configuration:
- Network first strategy
- 1-hour cache duration
- 3 retry attempts
- 50 MB cache limit

---

### Development Configuration

```dart
await OfflineSupport.initialize(
  config: OfflineConfig.development(),
);
```

Development settings:
- Debug mode enabled
- 5-minute cache (for testing)
- Frequent connectivity checks (10s)
- Verbose logging

---

### Production Configuration

```dart
await OfflineSupport.initialize(
  config: OfflineConfig.production(),
);
```

Production settings:
- Debug mode disabled
- 24-hour cache
- Background sync enabled
- Optimized performance

---

## Configuration

### Custom Configuration

```dart
await OfflineSupport.initialize(
  config: OfflineConfig(
    // === BASIC ===
    enabled: true,
    debugMode: false,
    environment: 'staging',

    // === CACHE ===
    defaultCacheStrategy: CacheStrategyType.networkFirst,
    cacheDuration: Duration(hours: 2),
    maxCacheSizeInMB: 100,              // 100 MB limit
    maxCacheEntries: 1000,              // Max 1000 items
    cacheCompression: true,             // Enable compression
    excludeHeaders: ['Authorization'],  // Don't cache auth headers

    // === QUEUE ===
    enableRequestQueue: true,
    maxQueueSize: 100,                  // Max 100 queued requests
    queuePersistence: true,             // Persist across restarts
    retryAttempts: 5,                   // Max 5 retries
    retryDelay: Duration(seconds: 2),   // Initial delay: 2s
    retryMultiplier: 2.0,               // Exponential backoff: 2x
    maxRetryDelay: Duration(seconds: 60), // Max delay: 60s

    // === SYNC ===
    enableAutoSync: true,
    enableBackgroundSync: false,        // Requires platform setup
    syncInterval: Duration(minutes: 15), // Sync every 15 min
    syncOnAppStart: true,               // Sync when app starts
    syncTimeout: Duration(seconds: 120), // 2-minute timeout

    // === NETWORK ===
    connectivityCheckUrl: 'https://www.google.com',
    connectivityCheckInterval: Duration(seconds: 30),
    connectivityCheckTimeout: Duration(seconds: 5),
    requireInternetConnection: true,
  ),
);
```

---

### Configuration Options Explained

#### Cache Settings

```dart
cacheDuration: Duration(hours: 1)
```
Default TTL (time-to-live) for cached entries.

```dart
maxCacheSizeInMB: 50
```
Maximum cache size. When exceeded, oldest entries are evicted.

```dart
maxCacheEntries: 1000
```
Maximum number of cached items.

```dart
cacheCompression: false
```
Enable Gzip compression (slower writes, less storage).

```dart
excludeHeaders: ['Authorization', 'Cookie']
```
Headers to exclude from cache (for security).

---

#### Queue Settings

```dart
retryAttempts: 3
```
Maximum retry attempts for failed requests.

```dart
retryDelay: Duration(seconds: 1)
retryMultiplier: 2.0
maxRetryDelay: Duration(seconds: 30)
```
Retry delays: 1s → 2s → 4s → 8s (capped at 30s)

---

#### Sync Settings

```dart
enableAutoSync: true
```
Automatically sync when online.

```dart
syncInterval: Duration(minutes: 30)
```
Background sync interval (if enabled).

```dart
syncOnAppStart: true
```
Sync queued requests when app starts.

---

## Connectivity Setup

### Add Connectivity Package

To auto-detect network status, add:

```yaml
dependencies:
  connectivity_plus: ^6.0.5
```

---

### Basic Connectivity Check

```dart
import 'package:connectivity_plus/connectivity_plus.dart';

Future<bool> isOnline() async {
  final result = await Connectivity().checkConnectivity();
  return result != ConnectivityResult.none;
}
```

---

### Listen to Connectivity Changes

```dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  StreamSubscription? _subscription;

  void startListening() {
    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        print('✅ Online - processing queue');
        processQueue();
      } else {
        print('❌ Offline - queueing requests');
      }
    });
  }

  void stopListening() {
    _subscription?.cancel();
  }

  Future<void> processQueue() async {
    // Implement queue processing
  }
}
```

---

### Platform Configuration for Connectivity

#### Android

No additional setup required.

#### iOS

Add to `ios/Runner/Info.plist`:

```xml
<key>NSLocalNetworkUsageDescription</key>
<string>Used to check network connectivity</string>
```

---

## Testing

### Test Module Initialization

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('Initializing offline support...');

  await OfflineSupport.initialize(
    config: OfflineConfig.development(),
  );

  print('✅ Initialization successful');

  // Test cache
  final cacheBox = Hive.box('offline_cache');
  await cacheBox.put('test_key', 'test_value');

  final value = cacheBox.get('test_key');
  print('Cache test: $value');  // Should print: test_value

  runApp(MyApp());
}
```

---

### Test Cache Operations

```dart
Future<void> testCache() async {
  final cacheBox = Hive.box('offline_cache');

  // 1. Write
  await cacheBox.put('user_123', {
    'name': 'John Doe',
    'email': 'john@example.com',
  });
  print('✅ Cache write successful');

  // 2. Read
  final user = cacheBox.get('user_123');
  print('✅ Cache read: $user');

  // 3. Check existence
  final exists = cacheBox.containsKey('user_123');
  print('✅ Key exists: $exists');

  // 4. Delete
  await cacheBox.delete('user_123');
  print('✅ Cache delete successful');

  // 5. Verify deletion
  final deleted = cacheBox.get('user_123');
  print('✅ After delete: $deleted');  // Should be null
}
```

---

### Test Request Queue

```dart
Future<void> testQueue() async {
  final queueBox = Hive.box('offline_queue');

  // 1. Add request
  final request = OfflineRequest(
    id: '1',
    method: 'POST',
    url: 'https://api.example.com/test',
    body: {'test': true},
    createdAt: DateTime.now(),
  );

  await queueBox.add(request);
  print('✅ Request queued: ${queueBox.length} items');

  // 2. Read queue
  final queued = queueBox.values.toList();
  print('✅ Queue contents: $queued');

  // 3. Clear queue
  await queueBox.clear();
  print('✅ Queue cleared');
}
```

---

### Test Metadata

```dart
Future<void> testMetadata() async {
  final metadataBox = Hive.box('offline_metadata');

  // 1. Create metadata
  final metadata = CacheMetadata(
    key: 'test_key',
    createdAt: DateTime.now(),
    expiresAt: DateTime.now().add(Duration(hours: 1)),
    sizeInBytes: 1024,
    accessCount: 0,
  );

  await metadataBox.put('test_key', metadata);
  print('✅ Metadata saved');

  // 2. Read metadata
  final stored = metadataBox.get('test_key') as CacheMetadata;
  print('✅ Created at: ${stored.createdAt}');
  print('✅ Expires at: ${stored.expiresAt}');
  print('✅ Is expired: ${stored.isExpired}');

  // 3. Update access count
  stored.incrementAccessCount();
  await metadataBox.put('test_key', stored);
  print('✅ Access count: ${stored.accessCount}');
}
```

---

### Test Complete Flow

```dart
Future<void> testCompleteFlow() async {
  print('=== Testing Complete Offline Flow ===');

  // 1. Initialize
  await OfflineSupport.initialize(
    config: OfflineConfig.development(),
  );
  print('✅ Module initialized');

  // 2. Cache data
  final cacheBox = Hive.box('offline_cache');
  await cacheBox.put('api_response', {'data': [1, 2, 3]});
  print('✅ Data cached');

  // 3. Queue request
  final queueBox = Hive.box('offline_queue');
  await queueBox.add(OfflineRequest(
    id: '1',
    method: 'POST',
    url: '/api/test',
    createdAt: DateTime.now(),
  ));
  print('✅ Request queued');

  // 4. Get stats
  print('Cache entries: ${cacheBox.length}');
  print('Queue size: ${queueBox.length}');

  // 5. Cleanup
  await OfflineSupport.clearAllData();
  print('✅ Data cleared');
}
```

---

## Troubleshooting

### ❌ "OfflineSupport has not been initialized"

**Cause:** Trying to access `OfflineSupport.config` before initialization.

**Fix:**
```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize BEFORE using any offline features
  await OfflineSupport.initialize();

  runApp(MyApp());
}
```

---

### ❌ "HiveError: Box not found"

**Cause:** Box not opened or wrong name.

**Fix:**
```dart
// Correct box names
final cacheBox = Hive.box('offline_cache');     // ✅
final queueBox = Hive.box('offline_queue');     // ✅
final metadataBox = Hive.box('offline_metadata'); // ✅

// Wrong
final box = Hive.box('cache');  // ❌ Wrong name
```

---

### ❌ "Type adapter not registered"

**Cause:** Hive adapter not registered or `.g.dart` files missing.

**Fix:**
```bash
# Regenerate adapters
flutter pub run build_runner build --delete-conflicting-outputs

# Then restart app
flutter clean
flutter run
```

---

### ❌ "Cannot open Hive box: FileSystemException"

**Cause:** Hive trying to access storage before initialization.

**Fix:**
```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Call initFlutter FIRST
  await Hive.initFlutter();  // ✅

  // Then open boxes
  await Hive.openBox('offline_cache');

  runApp(MyApp());
}

// Or just use OfflineSupport.initialize() which does all this
```

---

### ❌ "Hive box already open"

**Cause:** Trying to open same box twice.

**Fix:**
```dart
// Check if already open
if (!Hive.isBoxOpen('offline_cache')) {
  await Hive.openBox('offline_cache');
}

// Or just access it
final box = Hive.box('offline_cache');  // Works if already open
```

---

### ❌ "LateInitializationError: _instance"

**Cause:** Accessing singleton before initialization.

**Fix:**
```dart
// Wrong
final instance = OfflineSupport.instance;  // ❌

// Right
await OfflineSupport.initialize();
final instance = OfflineSupport.instance;  // ✅
```

---

### ❌ Data persists across app restarts

**This is expected behavior!** Hive persists data.

To clear:
```dart
// Clear all offline data
await OfflineSupport.clearAllData();

// Or clear specific box
final cacheBox = Hive.box('offline_cache');
await cacheBox.clear();
```

---

### ❌ "Build runner fails"

**Cause:** Missing dependencies or syntax errors in models.

**Fix:**
```bash
# Clean build cache
flutter clean

# Update dependencies
flutter pub get

# Regenerate
flutter pub run build_runner build --delete-conflicting-outputs
```

---

### ❌ Cache growing too large

**Fix:** Implement cache size management:
```dart
Future<void> manageCacheSize() async {
  final metadataBox = Hive.box('offline_metadata');
  int totalSize = 0;

  for (var key in metadataBox.keys) {
    final metadata = metadataBox.get(key) as CacheMetadata;
    totalSize += metadata.sizeInBytes;
  }

  final sizeMB = totalSize / (1024 * 1024);

  if (sizeMB > OfflineSupport.config.maxCacheSizeInMB) {
    // Clear expired entries
    await clearExpiredCache();

    // Or implement LRU eviction
    await evictLeastRecentlyUsed();
  }
}
```

---

## Platform-Specific Setup

### Android

No additional setup required. Hive works out of the box.

---

### iOS

No additional setup required. Hive works out of the box.

---

### Web

Hive uses IndexedDB on web:

```dart
// Use Hive.initFlutter() for all platforms
await Hive.initFlutter();

// No platform-specific code needed
```

---

### Linux/macOS/Windows

No additional setup required. Hive works on all desktop platforms.

---

## Setup Checklist

### Basic Setup
- [ ] Add Hive dependencies to pubspec.yaml
- [ ] Add connectivity_plus (optional)
- [ ] Copy connectivity_offline to lib/
- [ ] Run flutter pub get
- [ ] Verify `.g.dart` files exist
- [ ] Initialize OfflineSupport in main.dart
- [ ] Test cache read/write
- [ ] Test queue operations

### Advanced Setup
- [ ] Implement OfflineService wrapper
- [ ] Implement CachedHttpClient
- [ ] Implement QueueProcessor
- [ ] Setup auto-sync with connectivity
- [ ] Add offline banner UI
- [ ] Implement cache size management
- [ ] Setup periodic cleanup
- [ ] Add error handling
- [ ] Test offline scenarios
- [ ] Test queue processing

### Production Checklist
- [ ] Use OfflineConfig.production()
- [ ] Disable debug mode
- [ ] Set appropriate cache size limits
- [ ] Configure retry attempts
- [ ] Enable background sync (if needed)
- [ ] Test on physical devices
- [ ] Monitor cache size in production
- [ ] Setup analytics for sync failures

---

## Quick Start Script

```dart
// lib/quick_start.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'connectivity_offline/offline_support.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize
  await OfflineSupport.initialize(
    config: OfflineConfig.development(),
  );

  // Test it works
  final box = Hive.box('offline_cache');
  await box.put('hello', 'world');
  print('Offline support ready! Test value: ${box.get('hello')}');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Offline Support')),
        body: Center(
          child: Text('Offline support is ready!'),
        ),
      ),
    );
  }
}
```

Run:
```bash
flutter run -t lib/quick_start.dart
```

---

**Setup complete! Ready to build offline-first apps.**
