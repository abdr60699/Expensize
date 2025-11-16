# Offline Support Module - Demo Application

A production-ready Flutter offline support and connectivity management solution with local caching and request queuing capabilities.

## Features

- **Local Caching**: Store data locally using Hive for fast offline access
- **Request Queue**: Queue network requests when offline and sync when connection is restored
- **Cache Metadata**: Track cache entries with expiration, size, and access count
- **Priority Queuing**: Assign priorities to queued requests (high, normal, low)
- **Flexible Configuration**: Configurable cache policies, sync strategies, and more

## Prerequisites

- Flutter SDK (>=3.4.1 <4.0.0)
- Dart SDK
- Android Studio / VS Code (for development)
- An Android/iOS emulator or physical device

## Installation & Setup

### 1. Navigate to the project directory

```bash
cd feature_test/offline
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. (Optional) Regenerate Hive Adapters

If you make changes to the model classes, regenerate the Hive type adapters:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Run the application

```bash
flutter run
```

Or select your device/emulator in your IDE and press Run.

## Project Structure

```
lib/
├── main.dart                          # Demo app showcasing offline features
└── connectivity_offline/
    ├── offline_support.dart           # Main module entry point
    ├── config/
    │   ├── offline_config.dart        # Configuration options
    │   ├── cache_policy.dart          # Cache policies
    │   └── sync_policy.dart           # Sync policies
    ├── models/
    │   ├── cache_metadata.dart        # Cache metadata model
    │   ├── cache_metadata.g.dart      # Generated Hive adapter
    │   ├── offline_request.dart       # Queued request model
    │   ├── offline_request.g.dart     # Generated Hive adapter
    │   ├── connectivity_state.dart    # Connectivity state model
    │   ├── sync_result.dart           # Sync operation result
    │   └── network_request_info.dart  # Network request information
    └── exceptions/
        ├── offline_exception.dart     # Base offline exception
        ├── cache_exception.dart       # Cache-related exceptions
        └── sync_exception.dart        # Sync-related exceptions
```

## Usage Guide

### Initializing the Module

The module is automatically initialized in `main.dart`:

```dart
await OfflineSupport.initialize(
  config: OfflineConfig.development(),
);
```

### Demo Application Features

The demo app provides a comprehensive UI to test the offline functionality:

#### 1. Add to Cache
- Enter a **Key** and **Value**
- Click "Add to Cache" button
- The data is stored locally with metadata (expiration, size, access count)
- View cached items in the list below

#### 2. Add to Queue
- Enter a **URL** in the Key field
- Enter optional **Body** data in the Value field
- Click "Add to Queue" button
- The request is queued for later processing
- View queued requests with their priority and retry count

#### 3. View Cache Details
- Tap any cached item to view full details:
  - Key and Data
  - Creation and expiration time
  - Size in bytes
  - Access count
  - Expiration status

#### 4. Clear All Data
- Click the trash icon in the app bar
- Clears all cached items and queued requests

#### 5. Refresh View
- Click the refresh icon to update the lists

## Configuration Options

### Development Configuration

```dart
OfflineConfig.development()
```

Features:
- Debug mode enabled
- 5-minute cache duration
- 10-second connectivity checks
- Verbose logging

### Production Configuration

```dart
OfflineConfig.production()
```

Features:
- Debug mode disabled
- 24-hour cache duration
- Background sync enabled
- Optimized for production use

### Custom Configuration

```dart
const OfflineConfig(
  enabled: true,
  debugMode: true,
  cacheDuration: Duration(hours: 2),
  maxCacheSizeInMB: 100,
  enableRequestQueue: true,
  retryAttempts: 5,
  // ... more options
)
```

## Models

### CacheMetadata
Tracks metadata for cached entries:
- Key and creation time
- Expiration time
- Size in bytes
- Access count and last accessed time
- Optional ETag and headers

### CacheEntry
Combines data with metadata:
- Key
- Data (any type)
- Metadata

### OfflineRequest
Represents a queued network request:
- ID, method, URL
- Headers and body
- Retry count and priority
- Error tracking

## Cache Strategies

The module supports multiple cache strategies (configured via `OfflineConfig`):

- **networkFirst**: Try network first, fallback to cache
- **cacheFirst**: Try cache first, fallback to network
- **cacheOnly**: Only use cached data
- **networkOnly**: Only use network (no caching)
- **staleWhileRevalidate**: Return cached data while fetching fresh data

## Hive Boxes

The module uses three Hive boxes:

1. **offline_cache**: Stores cached data entries
2. **offline_queue**: Stores queued requests
3. **offline_metadata**: Stores cache metadata

## Testing the Offline Functionality

### Test Scenario 1: Basic Caching
1. Add some key-value pairs to cache
2. View the cached items
3. Tap on items to see metadata
4. Verify expiration times and access counts

### Test Scenario 2: Request Queuing
1. Add multiple requests with different priorities
2. Observe the queue list
3. Note the creation times and retry counts

### Test Scenario 3: Data Persistence
1. Add cache items and queue requests
2. Close the app completely
3. Reopen the app
4. Verify all data is still present (Hive persistence)

### Test Scenario 4: Clear Data
1. Add various cached items and requests
2. Click the clear button
3. Verify all data is removed

## Troubleshooting

### Issue: "OfflineSupport has not been initialized"
**Solution**: Ensure `OfflineSupport.initialize()` is called before using the module, preferably in `main()`.

### Issue: Type adapter errors
**Solution**: Run the build_runner command to regenerate adapters:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: Hive box errors
**Solution**: Clear app data or call `OfflineSupport.clearAllData()` to reset all boxes.

## Future Enhancements

The module structure includes placeholders for:
- Connectivity Manager (auto-detect online/offline state)
- Cache Service (advanced caching strategies)
- Offline HTTP Client (intercept and cache HTTP requests)
- Request Queue Manager (auto-retry queued requests)
- Sync Manager (background synchronization)
- UI Widgets (offline banner, sync indicator)

## Dependencies

- `hive: ^2.2.3` - Fast, lightweight NoSQL database
- `hive_flutter: ^1.1.0` - Hive integration for Flutter
- `hive_generator: ^2.0.1` - Code generator for Hive type adapters
- `build_runner: ^2.4.9` - Build system for code generation

## License

This is a demo/test project for the Expensize application.

## Support

For issues or questions about this module, please refer to the main Expensize project documentation.
