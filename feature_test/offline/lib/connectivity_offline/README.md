# Connectivity & Offline Support Module

A comprehensive, production-ready Flutter module for handling connectivity monitoring and offline support with intelligent caching and synchronization.

## 📂 Module Structure

```
connectivity_offline/
├── lib/
│   └── connectivity_offline/
│       ├── models/              # Data models
│       ├── core/                # Core functionality
│       ├── config/              # Configuration classes
│       ├── exceptions/          # Custom exceptions
│       ├── widgets/             # UI components
│       ├── utils/               # Utility functions
│       └── offline_support.dart # Main entry point
├── test/                        # Unit and widget tests
├── example/                     # Example application
├── pubspec.yaml                 # Dependencies
└── README.md                    # This file
```

## 🚀 Features

- **Real-time Connectivity Monitoring**: Track network status changes
- **Intelligent Disk Caching**: Hive-based persistent storage
- **Multiple Cache Strategies**: FIFO, LRU, LFU, TTL-based
- **Offline Request Queue**: Queue and sync requests when online
- **Configurable Policies**: Flexible cache and sync policies
- **Platform Agnostic**: Works on iOS, Android, Web, and Desktop
- **Type-safe**: Full Dart null safety support

## 📦 Installation

Add to your project's `pubspec.yaml`:

```yaml
dependencies:
  connectivity_offline:
    path: ../modules/connectivity_offline
```

Or for a standalone project:

```bash
cd modules/connectivity_offline
flutter pub get
```

## 🔧 Quick Start

### 1. Initialize the Module

```dart
import 'package:connectivity_offline/offline_support.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize with default configuration
  await OfflineSupport.initialize();

  runApp(MyApp());
}
```

### 2. Monitor Connectivity

```dart
OfflineSupport.instance.connectivityStream.listen((state) {
  if (state.status == ConnectivityStatus.offline) {
    print('No internet connection');
  } else {
    print('Connected via ${state.connectionType}');
  }
});
```

### 3. Use Cache

```dart
// Store data
await OfflineSupport.instance.cache.put(
  'user_profile',
  {'name': 'John', 'email': 'john@example.com'},
);

// Retrieve data
final profile = await OfflineSupport.instance.cache.get('user_profile');
```

### 4. Queue Offline Requests

```dart
await OfflineSupport.instance.queue.add(OfflineRequest(
  id: 'update_profile',
  endpoint: '/api/user/profile',
  method: 'POST',
  body: {'name': 'John Doe'},
));

// Auto-syncs when connection is restored
```

## 📚 Detailed Documentation

See the main [README.md](lib/connectivity_offline/README.md) in the lib folder for:
- Complete API reference
- Configuration options
- Advanced usage patterns
- Best practices
- Troubleshooting guide

## 🧪 Running Tests

```bash
cd modules/connectivity_offline
flutter test
```

## 💡 Example App

Run the example application:

```bash
cd modules/connectivity_offline/example
flutter run
```

## 🔗 Integration

This module is designed to be easily integrated into any Flutter project. Simply add it as a dependency and initialize it in your app's entry point.

## 📄 License

MIT License - See LICENSE file for details
