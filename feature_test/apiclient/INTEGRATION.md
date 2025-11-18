# Integration Guide

How to integrate the API Client module into any Flutter application.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Basic Integration](#basic-integration)
- [Advanced Integration](#advanced-integration)
- [Repository Pattern](#repository-pattern)
- [Error Handling Strategy](#error-handling-strategy)
- [Best Practices](#best-practices)
- [Testing](#testing)
- [Migration Guide](#migration-guide)

---

## Prerequisites

### Required Dependencies

Your Flutter project needs:
- **Flutter SDK**: >=3.4.1 <4.0.0
- **Dart SDK**: >=3.4.1
- **dio**: For HTTP operations (automatically included)

---

## Installation

### Step 1: Copy Module to Your Project

```bash
# If using as a package
cp -r feature_test/apiclient /path/to/your/project/packages/apiclient

# OR include in your lib directory
cp -r feature_test/apiclient/lib/api_client /path/to/your/project/lib/
```

### Step 2: Add Dependencies

#### Option A: As a local package

```yaml
dependencies:
  apiclient:
    path: ./packages/apiclient
```

#### Option B: Inline (copy to lib/)

```yaml
dependencies:
  dio: ^5.4.0
```

### Step 3: Install Dependencies

```bash
flutter pub get
```

---

## Basic Integration

### Minimal Integration (5 minutes)

Create a simple API service wrapper:

```dart
// lib/services/api_service.dart
import 'package:apiclient/api_client.dart';

class AppApiService {
  static final AppApiService _instance = AppApiService._internal();
  factory AppApiService() => _instance;
  AppApiService._internal();

  late final ApiClient _client;
  late final TokenService _tokenService;

  void initialize() {
    _tokenService = TokenService();

    _client = ApiClient(
      config: ApiClientConfig(
        baseUrl: 'https://api.yourapp.com',
        enableLogging: true,
        enableRetry: true,
        maxRetries: 3,
        onRefreshToken: _refreshToken,
      ),
      tokenService: _tokenService,
    );
  }

  // Token refresh callback
  Future<ApiResponse<Map<String, dynamic>>> _refreshToken() async {
    final refreshToken = await _tokenService.getRefreshToken();

    if (refreshToken == null) {
      return ApiResponse.error(
        error: ApiError.unauthorized(message: 'No refresh token'),
      );
    }

    try {
      final response = await _client.dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(extra: {'skipAuth': true}),
      );

      if (response.statusCode == 200) {
        final newToken = response.data['access_token'];
        final newRefreshToken = response.data['refresh_token'];

        await _tokenService.saveToken(newToken);
        await _tokenService.saveRefreshToken(newRefreshToken);

        return ApiResponse.success(data: response.data);
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

  // Expose client
  ApiClient get client => _client;
  TokenService get tokenService => _tokenService;
}
```

### Initialize in main.dart

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'services/api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API service
  AppApiService().initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: HomeScreen(),
    );
  }
}
```

### Basic Usage

```dart
// lib/screens/user_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class UserScreen extends StatefulWidget {
  final int userId;

  UserScreen({required this.userId});

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final _api = AppApiService().client;
  User? _user;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final response = await _api.get<User>(
      '/users/${widget.userId}',
      fromJson: (json) => User.fromJson(json),
    );

    setState(() {
      _loading = false;
      if (response.success) {
        _user = response.data;
      } else {
        _error = response.error?.message ?? 'Failed to load user';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, style: TextStyle(color: Colors.red)),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadUser,
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(_user!.name)),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${_user!.email}'),
            Text('ID: ${_user!.id}'),
          ],
        ),
      ),
    );
  }
}
```

---

## Advanced Integration

### Comprehensive API Service

Create a full-featured API service with multiple endpoints:

```dart
// lib/services/api_service.dart
import 'package:apiclient/api_client.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../models/order.dart';

class AppApiService {
  static final AppApiService _instance = AppApiService._internal();
  factory AppApiService() => _instance;
  AppApiService._internal();

  late final ApiClient _client;
  late final TokenService _tokenService;

  // Service state
  bool _initialized = false;

  void initialize({
    required String baseUrl,
    Map<String, String>? defaultHeaders,
  }) {
    if (_initialized) return;

    _tokenService = TokenService();

    _client = ApiClient(
      config: ApiClientConfig(
        baseUrl: baseUrl,
        enableLogging: kDebugMode,
        enableRetry: true,
        maxRetries: 3,
        connectTimeout: Duration(seconds: 30),
        receiveTimeout: Duration(seconds: 30),
        defaultHeaders: {
          'X-App-Version': '1.0.0',
          'X-Platform': defaultTargetPlatform.name,
          ...?defaultHeaders,
        },
        onRefreshToken: _refreshToken,
      ),
      tokenService: _tokenService,
    );

    _initialized = true;
  }

  // ==================== Authentication ====================

  Future<ApiResponse<AuthResponse>> login(
    String email,
    String password,
  ) async {
    final response = await _client.post<AuthResponse>(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
      fromJson: (json) => AuthResponse.fromJson(json),
    );

    if (response.success && response.data != null) {
      // Save tokens
      await _tokenService.saveToken(response.data!.accessToken);
      await _tokenService.saveRefreshToken(response.data!.refreshToken);
    }

    return response;
  }

  Future<ApiResponse<AuthResponse>> register(
    Map<String, dynamic> userData,
  ) async {
    return await _client.post<AuthResponse>(
      '/auth/register',
      data: userData,
      fromJson: (json) => AuthResponse.fromJson(json),
    );
  }

  Future<void> logout() async {
    await _client.post('/auth/logout');
    await _tokenService.clearTokens();
  }

  Future<ApiResponse<Map<String, dynamic>>> _refreshToken() async {
    final refreshToken = await _tokenService.getRefreshToken();

    if (refreshToken == null) {
      return ApiResponse.error(
        error: ApiError.unauthorized(message: 'No refresh token'),
      );
    }

    try {
      final response = await _client.dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(extra: {'skipAuth': true}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await _tokenService.saveToken(data['access_token']);
        await _tokenService.saveRefreshToken(data['refresh_token']);
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

  // ==================== Users ====================

  Future<ApiResponse<User>> getUser(int id) async {
    return await _client.get<User>(
      '/users/$id',
      fromJson: (json) => User.fromJson(json),
    );
  }

  Future<ApiResponse<User>> updateUser(
    int id,
    Map<String, dynamic> data,
  ) async {
    return await _client.patch<User>(
      '/users/$id',
      data: data,
      fromJson: (json) => User.fromJson(json),
    );
  }

  Future<ApiResponse<void>> deleteUser(int id) async {
    return await _client.delete('/users/$id');
  }

  // ==================== Products ====================

  Future<ApiResponse<PaginatedResponse<Product>>> getProducts(
    PaginationParams params,
  ) async {
    return await _client.get<PaginatedResponse<Product>>(
      '/products',
      queryParameters: params.toQueryParams(),
      fromJson: (json) => PaginatedResponse.fromJson(
        json,
        (item) => Product.fromJson(item),
      ),
    );
  }

  Future<ApiResponse<Product>> getProduct(int id) async {
    return await _client.get<Product>(
      '/products/$id',
      fromJson: (json) => Product.fromJson(json),
    );
  }

  Future<ApiResponse<Product>> createProduct(
    Map<String, dynamic> data,
  ) async {
    return await _client.post<Product>(
      '/products',
      data: data,
      fromJson: (json) => Product.fromJson(json),
    );
  }

  // ==================== Orders ====================

  Future<ApiResponse<List<Order>>> getOrders() async {
    return await _client.get<List<Order>>(
      '/orders',
      fromJson: (json) => (json as List)
          .map((item) => Order.fromJson(item))
          .toList(),
    );
  }

  Future<ApiResponse<Order>> createOrder(
    Map<String, dynamic> orderData,
  ) async {
    return await _client.post<Order>(
      '/orders',
      data: orderData,
      fromJson: (json) => Order.fromJson(json),
    );
  }

  // ==================== File Operations ====================

  Future<ApiResponse<UploadResult>> uploadFile(
    String filePath, {
    void Function(int, int)? onProgress,
  }) async {
    return await _client.uploadFile<UploadResult>(
      '/upload',
      filePath,
      onSendProgress: onProgress,
      fromJson: (json) => UploadResult.fromJson(json),
    );
  }

  // ==================== Getters ====================

  ApiClient get client => _client;
  TokenService get tokenService => _tokenService;
  bool get isInitialized => _initialized;
}
```

---

## Repository Pattern

Organize API calls using the repository pattern:

```dart
// lib/repositories/user_repository.dart
import 'package:apiclient/api_client.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class UserRepository {
  final ApiClient _api = AppApiService().client;

  Future<User> getUser(int id) async {
    final response = await _api.get<User>(
      '/users/$id',
      fromJson: (json) => User.fromJson(json),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw ApiException(response.error!);
  }

  Future<User> updateUser(int id, Map<String, dynamic> updates) async {
    final response = await _api.patch<User>(
      '/users/$id',
      data: updates,
      fromJson: (json) => User.fromJson(json),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw ApiException(response.error!);
  }

  Future<void> deleteUser(int id) async {
    final response = await _api.delete('/users/$id');

    if (!response.success) {
      throw ApiException(response.error!);
    }
  }

  Future<List<User>> searchUsers(String query) async {
    final response = await _api.get<List<User>>(
      '/users/search',
      queryParameters: {'q': query},
      fromJson: (json) => (json as List)
          .map((item) => User.fromJson(item))
          .toList(),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw ApiException(response.error!);
  }
}

// Custom exception
class ApiException implements Exception {
  final ApiError error;

  ApiException(this.error);

  @override
  String toString() => error.message;
}
```

### Using Repository in UI

```dart
// lib/screens/user_list_screen.dart
import 'package:flutter/material.dart';
import '../repositories/user_repository.dart';
import '../models/user.dart';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final _repository = UserRepository();
  List<User> _users = [];
  bool _loading = false;
  String? _error;

  Future<void> _searchUsers(String query) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final users = await _repository.searchUsers(query);
      setState(() {
        _users = users;
        _loading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.error.message;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Users')),
      body: Column(
        children: [
          TextField(
            onSubmitted: _searchUsers,
            decoration: InputDecoration(hintText: 'Search users...'),
          ),
          if (_loading) CircularProgressIndicator(),
          if (_error != null) Text(_error!, style: TextStyle(color: Colors.red)),
          Expanded(
            child: ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return ListTile(
                  title: Text(user.name),
                  subtitle: Text(user.email),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## Error Handling Strategy

### Global Error Handler

```dart
// lib/utils/api_error_handler.dart
import 'package:flutter/material.dart';
import 'package:apiclient/api_client.dart';

class ApiErrorHandler {
  static void handle(
    BuildContext context,
    ApiError error, {
    VoidCallback? onUnauthorized,
    VoidCallback? onRetry,
  }) {
    switch (error.code) {
      case 'NETWORK_ERROR':
        _showSnackbar(
          context,
          'No internet connection',
          action: onRetry != null
              ? SnackBarAction(label: 'Retry', onPressed: onRetry)
              : null,
        );
        break;

      case 'TIMEOUT':
        _showSnackbar(
          context,
          'Request timed out',
          action: onRetry != null
              ? SnackBarAction(label: 'Retry', onPressed: onRetry)
              : null,
        );
        break;

      case 'UNAUTHORIZED':
        if (onUnauthorized != null) {
          onUnauthorized();
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
        break;

      case 'VALIDATION_ERROR':
        _showValidationErrors(context, error);
        break;

      case 'SERVER_ERROR':
        _showSnackbar(
          context,
          'Server error. Please try again later.',
        );
        break;

      default:
        _showSnackbar(context, error.message);
    }
  }

  static void _showSnackbar(
    BuildContext context,
    String message, {
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: action,
      ),
    );
  }

  static void _showValidationErrors(
    BuildContext context,
    ApiError error,
  ) {
    if (error.fieldErrors == null) {
      _showSnackbar(context, error.message);
      return;
    }

    final errors = error.fieldErrors!.entries
        .map((e) => '${e.key}: ${e.value.join(', ')}')
        .join('\n');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Validation Errors'),
        content: Text(errors),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
```

### Usage

```dart
Future<void> _submitForm() async {
  final response = await _api.post<User>(
    '/users',
    data: formData,
    fromJson: (json) => User.fromJson(json),
  );

  if (response.success) {
    // Handle success
    Navigator.pop(context);
  } else {
    // Handle error
    ApiErrorHandler.handle(
      context,
      response.error!,
      onRetry: _submitForm,
      onUnauthorized: () => _handleLogout(),
    );
  }
}
```

---

## Best Practices

### 1. Environment Configuration

```dart
// lib/config/api_config.dart
class ApiConfig {
  static String get baseUrl {
    if (kReleaseMode) {
      return 'https://api.prod.yourapp.com';
    } else if (kProfileMode) {
      return 'https://api.staging.yourapp.com';
    } else {
      return 'https://api.dev.yourapp.com';
    }
  }

  static bool get enableLogging => kDebugMode;
}

// Initialize with environment
AppApiService().initialize(
  baseUrl: ApiConfig.baseUrl,
);
```

### 2. Loading States

```dart
class ApiState<T> {
  final bool loading;
  final T? data;
  final ApiError? error;

  ApiState({
    this.loading = false,
    this.data,
    this.error,
  });

  ApiState.loading() : this(loading: true);
  ApiState.success(T data) : this(data: data);
  ApiState.error(ApiError error) : this(error: error);

  bool get hasData => data != null;
  bool get hasError => error != null;
}

// Usage
class MyScreen extends StatefulWidget {
  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  ApiState<User> _state = ApiState.loading();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _state = ApiState.loading());

    final response = await _api.get<User>(...);

    setState(() {
      if (response.success && response.data != null) {
        _state = ApiState.success(response.data!);
      } else {
        _state = ApiState.error(response.error!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_state.loading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_state.hasError) {
      return ErrorWidget(error: _state.error!);
    }

    return DataWidget(user: _state.data!);
  }
}
```

### 3. Request Cancellation

```dart
// Cancel in-flight requests on dispose
class MyScreen extends StatefulWidget {
  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  CancelToken? _cancelToken;

  Future<void> _loadData() async {
    _cancelToken = CancelToken();

    final response = await _api.get(
      '/data',
      options: Options(cancelToken: _cancelToken),
    );

    // Handle response
  }

  @override
  void dispose() {
    _cancelToken?.cancel('Screen disposed');
    super.dispose();
  }
}
```

### 4. Caching Strategy

```dart
// lib/utils/api_cache.dart
class ApiCache {
  static final Map<String, CachedResponse> _cache = {};

  static Future<ApiResponse<T>> getOrFetch<T>(
    String key,
    Future<ApiResponse<T>> Function() fetcher, {
    Duration ttl = const Duration(minutes: 5),
  }) async {
    final cached = _cache[key];

    if (cached != null && !cached.isExpired) {
      return cached.response as ApiResponse<T>;
    }

    final response = await fetcher();

    if (response.success) {
      _cache[key] = CachedResponse(
        response: response,
        expiresAt: DateTime.now().add(ttl),
      );
    }

    return response;
  }

  static void clear([String? key]) {
    if (key != null) {
      _cache.remove(key);
    } else {
      _cache.clear();
    }
  }
}

class CachedResponse {
  final ApiResponse response;
  final DateTime expiresAt;

  CachedResponse({required this.response, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

// Usage
final response = await ApiCache.getOrFetch(
  'user_${userId}',
  () => _api.get<User>('/users/$userId', ...),
  ttl: Duration(minutes: 10),
);
```

---

## Testing

### Mock API Client

```dart
// test/mocks/mock_api_client.dart
import 'package:apiclient/api_client.dart';
import 'package:mockito/mockito.dart';

class MockApiClient extends Mock implements ApiClient {}

// Usage in tests
void main() {
  late MockApiClient mockApiClient;
  late UserRepository repository;

  setUp(() {
    mockApiClient = MockApiClient();
    repository = UserRepository(apiClient: mockApiClient);
  });

  test('getUser returns user on success', () async {
    final user = User(id: 1, name: 'John Doe', email: 'john@example.com');

    when(mockApiClient.get<User>(
      any,
      fromJson: anyNamed('fromJson'),
    )).thenAnswer((_) async => ApiResponse.success(data: user));

    final result = await repository.getUser(1);

    expect(result, equals(user));
    verify(mockApiClient.get<User>('/users/1', fromJson: anyNamed('fromJson')));
  });

  test('getUser throws on error', () async {
    when(mockApiClient.get<User>(
      any,
      fromJson: anyNamed('fromJson'),
    )).thenAnswer((_) async => ApiResponse.error(
      error: ApiError.notFound(message: 'User not found'),
    ));

    expect(
      () => repository.getUser(1),
      throwsA(isA<ApiException>()),
    );
  });
}
```

---

## Migration Guide

### From http Package

**Before:**
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<User> getUser(int id) async {
  final response = await http.get(
    Uri.parse('https://api.example.com/users/$id'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    return User.fromJson(json.decode(response.body));
  }

  throw Exception('Failed to load user');
}
```

**After:**
```dart
import 'package:apiclient/api_client.dart';

Future<User> getUser(int id) async {
  final response = await apiClient.get<User>(
    '/users/$id',
    fromJson: (json) => User.fromJson(json),
  );

  if (response.success && response.data != null) {
    return response.data!;
  }

  throw ApiException(response.error!);
}
// Added: Type safety, automatic auth, retry, error handling
```

### From Direct Dio Usage

**Before:**
```dart
import 'package:dio/dio.dart';

final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));

Future<User> getUser(int id) async {
  try {
    final response = await dio.get('/users/$id');
    return User.fromJson(response.data);
  } on DioException catch (e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      throw Exception('Connection timeout');
    }
    throw Exception(e.message);
  }
}
```

**After:**
```dart
final response = await apiClient.get<User>(
  '/users/$id',
  fromJson: (json) => User.fromJson(json),
);

if (response.success && response.data != null) {
  return response.data!;
}

throw ApiException(response.error!);
// Added: Standardized errors, retry, auth, logging
```

---

## Integration Checklist

- [ ] Copy apiclient module to your project
- [ ] Add dependencies to pubspec.yaml
- [ ] Run `flutter pub get`
- [ ] Create AppApiService wrapper
- [ ] Configure base URL and settings
- [ ] Implement token refresh logic
- [ ] Create model classes with fromJson
- [ ] Setup repositories (optional)
- [ ] Implement error handling
- [ ] Add loading states
- [ ] Test API calls
- [ ] Handle offline scenarios
- [ ] Add caching (if needed)
- [ ] Write tests

---

## Support

For integration issues:
1. Check the [SETUP.md](./SETUP.md) for configuration details
2. Review [FEATURES.md](./FEATURES.md) for feature documentation
3. See example implementations in `/lib/main.dart`
4. Check Dio documentation for advanced features
5. Open an issue in the repository

---

**Ready to integrate API calls into your app!**
