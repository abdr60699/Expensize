# Setup Guide

Complete guide to setting up the API Client module from scratch.

## Table of Contents

- [Quick Start](#quick-start)
- [Detailed Setup](#detailed-setup)
- [Configuration](#configuration)
- [Model Classes](#model-classes)
- [Token Management](#token-management)
- [Testing & Verification](#testing--verification)
- [Troubleshooting](#troubleshooting)

---

## Quick Start

Get up and running in 5 minutes:

```bash
# 1. Navigate to the module
cd feature_test/apiclient

# 2. Install dependencies
flutter pub get

# 3. Run the demo app
flutter run
```

---

## Detailed Setup

### Step 1: System Requirements

Verify you have the required tools:

```bash
# Check Flutter version
flutter --version
# Required: Flutter >=3.4.1

# Check Dart version
dart --version
# Required: Dart >=3.4.1

# Verify Flutter doctor
flutter doctor
# Ensure no critical issues
```

### Step 2: Add Dio Dependency

Since this module uses Dio, add it to your `pubspec.yaml`:

```yaml
dependencies:
  dio: ^5.4.0  # Latest stable version
```

```bash
flutter pub get
```

### Step 3: Copy Module Files

```bash
# Option A: As a package
mkdir -p packages
cp -r feature_test/apiclient packages/

# Add to pubspec.yaml
dependencies:
  apiclient:
    path: ./packages/apiclient

# Option B: Inline in lib/
cp -r feature_test/apiclient/lib/api_client lib/
```

### Step 4: Create API Service Wrapper

```dart
// lib/services/api_service.dart
import 'package:apiclient/api_client.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late ApiClient _client;
  late TokenService _tokenService;
  bool _initialized = false;

  void initialize({
    required String baseUrl,
  }) {
    if (_initialized) return;

    _tokenService = TokenService();

    _client = ApiClient(
      config: ApiClientConfig(
        baseUrl: baseUrl,
        enableLogging: kDebugMode,
        enableRetry: true,
        maxRetries: 3,
      ),
      tokenService: _tokenService,
    );

    _initialized = true;
  }

  ApiClient get client => _client;
  TokenService get tokenService => _tokenService;
}
```

### Step 5: Initialize in main.dart

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'services/api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API service
  ApiService().initialize(
    baseUrl: 'https://api.yourapp.com',
  );

  runApp(MyApp());
}
```

---

## Configuration

### Basic Configuration

```dart
final config = ApiClientConfig(
  baseUrl: 'https://api.yourapp.com',
  enableLogging: true,
  enableRetry: true,
  maxRetries: 3,
);

final apiClient = ApiClient(config: config);
```

### Advanced Configuration

```dart
final config = ApiClientConfig(
  baseUrl: 'https://api.yourapp.com',

  // Timeouts
  connectTimeout: Duration(seconds: 30),
  receiveTimeout: Duration(seconds: 30),
  sendTimeout: Duration(seconds: 30),

  // Logging (disable in production)
  enableLogging: kDebugMode,

  // Retry settings
  enableRetry: true,
  maxRetries: 3,

  // Default headers
  defaultHeaders: {
    'X-App-Version': '1.0.0',
    'X-Platform': 'mobile',
    'Accept-Language': 'en-US',
  },

  // Token refresh callback
  onRefreshToken: () async {
    // Implement token refresh logic
    return await refreshToken();
  },
);
```

### Environment-Specific Configuration

```dart
// lib/config/api_config.dart
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kReleaseMode) {
      return 'https://api.prod.yourapp.com';
    } else if (kProfileMode) {
      return 'https://api.staging.yourapp.com';
    } else {
      // Debug mode
      return 'https://api.dev.yourapp.com';
    }
  }

  static bool get enableLogging => kDebugMode;

  static int get maxRetries {
    return kDebugMode ? 1 : 3;  // Fewer retries in debug
  }

  static Duration get connectTimeout {
    return kDebugMode
        ? Duration(seconds: 60)  // Longer for debugging
        : Duration(seconds: 30);
  }
}

// Usage
ApiService().initialize(
  baseUrl: ApiConfig.baseUrl,
);
```

---

## Model Classes

### Create Model Classes with fromJson

All models need a `fromJson` factory constructor:

```dart
// lib/models/user.dart
class User {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
```

### Nested Models

```dart
// lib/models/order.dart
class Order {
  final int id;
  final User customer;
  final List<OrderItem> items;
  final double total;
  final OrderStatus status;

  Order({
    required this.id,
    required this.customer,
    required this.items,
    required this.total,
    required this.status,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      customer: User.fromJson(json['customer']),
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      total: json['total'].toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
    );
  }
}

class OrderItem {
  final int id;
  final String name;
  final int quantity;
  final double price;

  OrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      price: json['price'].toDouble(),
    );
  }
}

enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled,
}
```

### Using json_serializable (Optional)

For automatic JSON serialization:

```yaml
# pubspec.yaml
dev_dependencies:
  json_serializable: ^6.7.1
  build_runner: ^2.4.7
```

```dart
// lib/models/user.dart
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String name;
  final String email;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
```

```bash
# Generate code
flutter pub run build_runner build
```

---

## Token Management

### Token Service Setup

The `TokenService` manages access and refresh tokens:

```dart
// Automatic - already included in ApiClient
final tokenService = TokenService();

// Save tokens after login
await tokenService.saveToken('your_access_token');
await tokenService.saveRefreshToken('your_refresh_token');

// Get tokens
final token = await tokenService.getToken();
final refreshToken = await tokenService.getRefreshToken();

// Clear tokens (on logout)
await tokenService.clearTokens();
```

### Secure Token Storage

By default, tokens are stored in SharedPreferences. For better security, use flutter_secure_storage:

```yaml
# pubspec.yaml
dependencies:
  flutter_secure_storage: ^9.0.0
```

```dart
// lib/services/secure_token_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureTokenService implements TokenService {
  final _storage = FlutterSecureStorage();

  @override
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  @override
  Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: 'refresh_token', value: token);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  @override
  Future<void> clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  @override
  Future<String?> getAuthorizationHeader() async {
    final token = await getToken();
    return token != null ? 'Bearer $token' : null;
  }
}

// Use in ApiClient
final apiClient = ApiClient(
  config: config,
  tokenService: SecureTokenService(),
);
```

### Token Refresh Implementation

```dart
Future<ApiResponse<Map<String, dynamic>>> _refreshToken() async {
  final refreshToken = await _tokenService.getRefreshToken();

  if (refreshToken == null) {
    // No refresh token, user needs to login
    return ApiResponse.error(
      error: ApiError.unauthorized(message: 'No refresh token available'),
    );
  }

  try {
    // Call refresh endpoint
    final response = await _client.dio.post(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
      options: Options(extra: {'skipAuth': true}),
    );

    if (response.statusCode == 200) {
      final data = response.data;

      // Save new tokens
      await _tokenService.saveToken(data['access_token']);

      if (data['refresh_token'] != null) {
        await _tokenService.saveRefreshToken(data['refresh_token']);
      }

      return ApiResponse.success(data: data);
    }

    return ApiResponse.error(
      error: ApiError.unauthorized(message: 'Token refresh failed'),
    );
  } catch (e) {
    return ApiResponse.error(
      error: ApiError.unknown(message: e.toString()),
    );
  }
}

// Configure in ApiClient
final apiClient = ApiClient(
  config: ApiClientConfig(
    baseUrl: 'https://api.yourapp.com',
    onRefreshToken: _refreshToken,
  ),
);
```

---

## Testing & Verification

### 1. Test Basic Request

```dart
// Create a simple test
Future<void> testApiConnection() async {
  final response = await apiClient.get(
    '/health',
    options: Options(extra: {'skipAuth': true}),
  );

  if (response.success) {
    print('✅ API connection successful');
    print('Response: ${response.data}');
  } else {
    print('❌ API connection failed');
    print('Error: ${response.error?.message}');
  }
}
```

### 2. Test Authentication

```dart
Future<void> testLogin() async {
  final response = await apiClient.post<AuthResponse>(
    '/auth/login',
    data: {
      'email': 'test@example.com',
      'password': 'password123',
    },
    fromJson: (json) => AuthResponse.fromJson(json),
  );

  if (response.success && response.data != null) {
    print('✅ Login successful');
    print('Token: ${response.data!.accessToken}');

    // Save token
    await tokenService.saveToken(response.data!.accessToken);
  } else {
    print('❌ Login failed');
    print('Error: ${response.error?.message}');
  }
}
```

### 3. Test Authenticated Request

```dart
Future<void> testAuthenticatedRequest() async {
  final response = await apiClient.get<User>(
    '/me',
    fromJson: (json) => User.fromJson(json),
  );

  if (response.success && response.data != null) {
    print('✅ Authenticated request successful');
    print('User: ${response.data!.name}');
  } else {
    print('❌ Authenticated request failed');
    print('Error: ${response.error?.message}');
  }
}
```

### 4. Test Error Handling

```dart
Future<void> testErrorHandling() async {
  // Test 404
  final response404 = await apiClient.get('/nonexistent');
  assert(response404.error?.code == 'NOT_FOUND');
  print('✅ 404 error handled correctly');

  // Test network error (invalid URL)
  final apiClientInvalid = ApiClient(
    config: ApiClientConfig(baseUrl: 'https://invalid-url-12345.com'),
  );
  final responseNetwork = await apiClientInvalid.get('/test');
  assert(responseNetwork.error?.code == 'NETWORK_ERROR');
  print('✅ Network error handled correctly');
}
```

### 5. Test Pagination

```dart
Future<void> testPagination() async {
  final params = PaginationParams(
    page: 1,
    pageSize: 10,
    sortBy: 'created_at',
    sortDirection: 'desc',
  );

  final response = await apiClient.get<PaginatedResponse<Product>>(
    '/products',
    queryParameters: params.toQueryParams(),
    fromJson: (json) => PaginatedResponse.fromJson(
      json,
      (item) => Product.fromJson(item),
    ),
  );

  if (response.success && response.data != null) {
    final paginated = response.data!;
    print('✅ Pagination working');
    print('Items: ${paginated.itemCount}');
    print('Page: ${paginated.currentPage}/${paginated.totalPages}');
    print('Has next: ${paginated.hasNext}');
  }
}
```

### 6. Run All Tests

```dart
// lib/main.dart (debug mode)
Future<void> runApiTests() async {
  print('🧪 Running API tests...\n');

  await testApiConnection();
  await testLogin();
  await testAuthenticatedRequest();
  await testErrorHandling();
  await testPagination();

  print('\n✅ All tests completed');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API
  ApiService().initialize(baseUrl: 'https://api.yourapp.com');

  // Run tests in debug mode
  if (kDebugMode) {
    await runApiTests();
  }

  runApp(MyApp());
}
```

---

## Troubleshooting

### Issue: "DioException: Connection refused"

**Cause**: Cannot connect to API server.

**Solutions:**
1. Check if API server is running
2. Verify base URL is correct
3. Check network connectivity
4. For Android emulator, use `10.0.2.2` instead of `localhost`

```dart
// Android emulator
final baseUrl = Platform.isAndroid
    ? 'http://10.0.2.2:3000'
    : 'http://localhost:3000';
```

---

### Issue: "DioException: Certificate verification failed"

**Cause**: SSL certificate issues (usually in development).

**Solution** (Development only):
```dart
import 'dart:io';

// ONLY for development with self-signed certificates
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

// In main.dart
void main() {
  if (kDebugMode) {
    HttpOverrides.global = MyHttpOverrides();
  }

  runApp(MyApp());
}
```

**Production Solution:**
- Use valid SSL certificates
- Never disable certificate verification in production

---

### Issue: "401 Unauthorized"

**Possible causes:**
1. No token saved
2. Token expired
3. Invalid token
4. Token refresh failed

**Solutions:**
```dart
// Check if token exists
final token = await tokenService.getToken();
if (token == null) {
  // Redirect to login
  Navigator.pushReplacementNamed(context, '/login');
  return;
}

// Implement proper token refresh
onRefreshToken: () async {
  final refreshToken = await tokenService.getRefreshToken();

  if (refreshToken == null) {
    // No refresh token, redirect to login
    Navigator.pushReplacementNamed(context, '/login');
    return ApiResponse.error(
      error: ApiError.unauthorized(),
    );
  }

  // Call refresh endpoint
  final response = await refreshTokens(refreshToken);
  return response;
}
```

---

### Issue: "Timeout Error"

**Cause:** Request taking too long.

**Solutions:**
1. Increase timeout duration:
```dart
final config = ApiClientConfig(
  baseUrl: baseUrl,
  connectTimeout: Duration(seconds: 60),
  receiveTimeout: Duration(seconds: 60),
);
```

2. Optimize API endpoint
3. Check network speed
4. Use pagination for large data sets

---

### Issue: "JSON Parsing Error"

**Cause:** Response format doesn't match model.

**Solution:**
```dart
// Add try-catch in fromJson
factory User.fromJson(Map<String, dynamic> json) {
  try {
    return User(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  } catch (e) {
    print('Error parsing User: $e');
    print('JSON: $json');
    rethrow;
  }
}
```

**Debug response:**
```dart
final response = await apiClient.get('/users/123');
print('Raw response: ${response.data}');  // Check actual format
```

---

### Issue: "Too many retries"

**Cause:** Request failing repeatedly.

**Solutions:**
1. Reduce retry count:
```dart
final config = ApiClientConfig(
  baseUrl: baseUrl,
  maxRetries: 1,  // Reduce from 3 to 1
);
```

2. Check if endpoint is working
3. Verify request data is valid
4. Check server logs

---

### Issue: "Headers not being sent"

**Solution:**
```dart
// Check headers are set correctly
final response = await apiClient.get(
  '/data',
  options: Options(
    headers: {
      'X-Custom-Header': 'value',
    },
  ),
);

// Or set default headers
final config = ApiClientConfig(
  baseUrl: baseUrl,
  defaultHeaders: {
    'X-App-Version': '1.0.0',
  },
);
```

**Debug headers:**
Enable logging to see actual headers sent:
```dart
final config = ApiClientConfig(
  baseUrl: baseUrl,
  enableLogging: true,  // Shows headers in console
);
```

---

## Setup Checklist

- [ ] Flutter SDK >=3.4.1 installed
- [ ] Dio dependency added
- [ ] API Client module copied to project
- [ ] Dependencies installed (`flutter pub get`)
- [ ] ApiService wrapper created
- [ ] Base URL configured
- [ ] Environment-specific configs setup
- [ ] Model classes created with fromJson
- [ ] Token service configured
- [ ] Token refresh implemented
- [ ] Basic request tested
- [ ] Authentication tested
- [ ] Error handling tested
- [ ] Pagination tested (if needed)

---

## Next Steps

1. ✅ Complete setup (you're here)
2. 📖 Read [FEATURES.md](./FEATURES.md) for capabilities
3. 🔧 Read [INTEGRATION.md](./INTEGRATION.md) for integration patterns
4. 💻 Check demo app in `/lib/main.dart`
5. 🚀 Start making API calls in your app!

---

## Getting Help

If you encounter issues:

1. Check this troubleshooting guide
2. Review [Dio documentation](https://pub.dev/packages/dio)
3. Enable debug logging
4. Check network requests in DevTools
5. Verify API responses with Postman/cURL
6. Open an issue in the repository

---

**Setup complete! You're ready to make API calls.**
