# API Client Module for Flutter

A production-ready, reusable API layer for Flutter apps using Dio. Drop-in ready with comprehensive features for modern mobile app development.

**Version**: 1.0.0
**Platform**: Android & iOS
**Null-Safety**: ✅ Full support

---

## Features

✅ **Modern HTTP Client** (Dio-based)
- GET, POST, PUT, PATCH, DELETE methods
- File upload/download with progress
- Request/response transformation
- Custom headers support

✅ **Authentication**
- Automatic token injection
- Token refresh flow
- Secure token storage
- Authorization header management

✅ **Error Handling**
- Standardized error mapping
- HTTP status code handling
- Field-specific validation errors
- Network error detection

✅ **Retry Logic**
- Automatic retry on failure
- Exponential backoff
- Token refresh on 401
- Configurable max retries

✅ **Interceptors**
- Authentication interceptor
- Retry interceptor with refresh
- Logging interceptor (formatted)
- Custom interceptor support

✅ **Pagination**
- Pagination helper classes
- Infinite scroll support
- Search and filtering
- Sort support

✅ **Production Features**
- Response caching (via Dio)
- Request cancellation
- Timeout configuration
- Certificate pinning support

---

## Installation

This module is part of the reusable_widgets project. Dependencies:

```yaml
dependencies:
  dio: ^5.4.0
  flutter_secure_storage: ^9.0.0

dev_dependencies:
  http_mock_adapter: ^0.6.0  # For testing
```

---

## Quick Start

### 1. Initialize API Client

```dart
import 'package:reuablewidgets/features/api_client/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API client
  final apiClient = ApiClient(
    config: ApiClientConfig(
      baseUrl: 'https://api.yourapp.com',
      enableLogging: true,
      enableRetry: true,
      maxRetries: 3,
      connectTimeout: Duration(seconds: 30),
      onRefreshToken: () async {
        // Implement token refresh logic
        return await refreshToken();
      },
    ),
  );

  runApp(MyApp(apiClient: apiClient));
}
```

### 2. Make API Calls

```dart
// GET request
final response = await apiClient.get<User>(
  '/users/123',
  fromJson: (json) => User.fromJson(json),
);

if (response.success) {
  final user = response.data;
  print('User: ${user?.name}');
} else {
  print('Error: ${response.error?.message}');
}

// POST request
final createResponse = await apiClient.post<User>(
  '/users',
  data: {
    'name': 'John Doe',
    'email': 'john@example.com',
  },
  fromJson: (json) => User.fromJson(json),
);

// PUT request
final updateResponse = await apiClient.put<User>(
  '/users/123',
  data: {'name': 'Jane Doe'},
  fromJson: (json) => User.fromJson(json),
);

// DELETE request
final deleteResponse = await apiClient.delete('/users/123');
```

---

## Authentication

### Automatic Token Injection

Tokens are automatically added to requests:

```dart
// Login and save token
final loginResponse = await apiClient.post<Map<String, dynamic>>(
  '/auth/login',
  data: {
    'email': 'user@example.com',
    'password': 'password',
  },
);

if (loginResponse.success) {
  final accessToken = loginResponse.data!['accessToken'];
  final refreshToken = loginResponse.data!['refreshToken'];

  // Save tokens
  await apiClient.tokenService.saveTokens(
    accessToken: accessToken,
    refreshToken: refreshToken,
    expiry: DateTime.now().add(Duration(hours: 1)),
  );

  // Future requests will automatically include the token
}
```

### Token Refresh Flow

Automatically refresh expired tokens:

```dart
final apiClient = ApiClient(
  config: ApiClientConfig(
    baseUrl: 'https://api.yourapp.com',
    onRefreshToken: () async {
      // Get refresh token
      final refreshToken = await apiClient.tokenService.getRefreshToken();

      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      // Call refresh endpoint
      final response = await apiClient.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (!response.success) {
        throw Exception('Token refresh failed');
      }

      return response;
    },
  ),
);
```

### Skip Authentication for Specific Requests

```dart
final response = await apiClient.get(
  '/public/data',
  options: Options(
    extra: {'skipAuth': true},
  ),
);
```

---

## Error Handling

### Standardized Error Types

```dart
final response = await apiClient.get<User>('/users/123');

if (response.hasError) {
  final error = response.error!;

  switch (error.code) {
    case 'NETWORK_ERROR':
      showError('No internet connection');
      break;

    case 'UNAUTHORIZED':
      // Redirect to login
      Navigator.pushNamed(context, '/login');
      break;

    case 'VALIDATION_ERROR':
      // Show field errors
      if (error.fieldErrors != null) {
        error.fieldErrors!.forEach((field, errors) {
          print('$field: ${errors.join(", ")}');
        });
      }
      break;

    case 'NOT_FOUND':
      showError('Resource not found');
      break;

    case 'SERVER_ERROR':
      showError('Server error. Please try again later.');
      break;

    default:
      showError(error.message);
  }
}
```

### Retryable Errors

```dart
if (response.hasError && response.error!.isRetryable) {
  // Show retry button
  showRetryButton(() {
    // Retry the request
    makeRequest();
  });
}
```

---

## Pagination

### Using Pagination Params

```dart
// Create pagination params
var params = PaginationParams(
  page: 1,
  pageSize: 20,
  sortBy: 'createdAt',
  sortDirection: 'desc',
);

// Convert to query parameters
final queryParams = params.toQueryParams();

// Make request
final response = await apiClient.get<PaginatedResponse<User>>(
  '/users',
  queryParameters: queryParams,
  fromJson: (json) => PaginatedResponse<User>.fromJson(
    json,
    (item) => User.fromJson(item),
  ),
);

if (response.success && response.data != null) {
  final paginatedData = response.data!;

  print('Items: ${paginatedData.items.length}');
  print('Page: ${paginatedData.currentPage}/${paginatedData.totalPages}');
  print('Total: ${paginatedData.totalItems}');
  print('Has next: ${paginatedData.hasNext}');
}
```

### Using Pagination Controller

```dart
// Create controller
final controller = PaginationController<User>(
  fetchData: (params) async {
    final response = await apiClient.get<PaginatedResponse<User>>(
      '/users',
      queryParameters: params.toQueryParams(),
      fromJson: (json) => PaginatedResponse<User>.fromJson(
        json,
        (item) => User.fromJson(item),
      ),
    );

    if (!response.success) {
      throw Exception(response.error?.message ?? 'Failed to load data');
    }

    return response.data!;
  },
);

// Load first page
await controller.loadFirstPage();

// Load more (for infinite scroll)
await controller.loadNextPage();

// Search
await controller.search('john');

// Filter
await controller.filter({'status': 'active'});

// Sort
await controller.sort('name', sortDirection: 'asc');

// Refresh
await controller.refresh();

// Access data
print('Loaded ${controller.allItems.length} items');
print('Has more: ${controller.hasMore}');
```

### UI Integration (ListView)

```dart
class UsersListScreen extends StatefulWidget {
  @override
  _UsersListScreenState createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  late PaginationController<User> controller;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    controller = PaginationController<User>(
      fetchData: (params) => fetchUsers(params),
    );

    // Load first page
    controller.loadFirstPage();

    // Listen for scroll to load more
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        if (controller.hasMore && !controller.isLoading) {
          controller.loadNextPage();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Users')),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView.builder(
          controller: scrollController,
          itemCount: controller.allItems.length + (controller.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.allItems.length) {
              return Center(child: CircularProgressIndicator());
            }

            final user = controller.allItems[index];
            return ListTile(
              title: Text(user.name),
              subtitle: Text(user.email),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
```

---

## File Upload/Download

### Upload File

```dart
final response = await apiClient.uploadFile<Map<String, dynamic>>(
  '/upload',
  '/path/to/file.jpg',
  fileKey: 'image',
  data: {
    'title': 'My Image',
    'description': 'Photo description',
  },
  onSendProgress: (sent, total) {
    final progress = (sent / total * 100).toStringAsFixed(0);
    print('Upload progress: $progress%');
  },
);

if (response.success) {
  print('File uploaded successfully');
  print('File URL: ${response.data!['url']}');
}
```

### Download File

```dart
final response = await apiClient.downloadFile(
  '/files/document.pdf',
  '/path/to/save/document.pdf',
  onReceiveProgress: (received, total) {
    final progress = (received / total * 100).toStringAsFixed(0);
    print('Download progress: $progress%');
  },
);

if (response.success) {
  print('File downloaded successfully');
}
```

---

## Logging

### Enable/Disable Logging

```dart
final apiClient = ApiClient(
  config: ApiClientConfig(
    baseUrl: 'https://api.yourapp.com',
    enableLogging: true,  // Enable in development
  ),
);
```

### Custom Logging Configuration

```dart
// Access dio instance for advanced configuration
apiClient.dio.interceptors.add(
  LoggingInterceptor(
    enableRequestLogging: true,
    enableResponseLogging: true,
    enableErrorLogging: true,
    logHeaders: true,
    logRequestBody: true,
    logResponseBody: true,
  ),
);
```

### Log Output

```
╔════════════════════════════════════════════════════════════════
║ 🌐 HTTP REQUEST
╠════════════════════════════════════════════════════════════════
║ GET https://api.example.com/users/123
╟────────────────────────────────────────────────────────────────
║ Headers:
║   Authorization: Bear****1234
║   Content-Type: application/json
╚════════════════════════════════════════════════════════════════

╔════════════════════════════════════════════════════════════════
║ ✅ HTTP RESPONSE
╠════════════════════════════════════════════════════════════════
║ GET https://api.example.com/users/123
║ Status: 200 OK
╟────────────────────────────────────────────────────────────────
║ Body:
║ {id: 123, name: John Doe, email: john@example.com}
╚════════════════════════════════════════════════════════════════
```

---

## Configuration

### Full Configuration Options

```dart
final apiClient = ApiClient(
  config: ApiClientConfig(
    // Required
    baseUrl: 'https://api.yourapp.com',

    // Optional timeouts
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 30),
    sendTimeout: Duration(seconds: 30),

    // Logging
    enableLogging: true,

    // Retry configuration
    enableRetry: true,
    maxRetries: 3,

    // Default headers
    defaultHeaders: {
      'X-App-Version': '1.0.0',
      'X-Platform': 'mobile',
    },

    // Token refresh callback
    onRefreshToken: () async {
      return await refreshToken();
    },
  ),
  // Optional custom token service
  tokenService: TokenService(),
);
```

---

## Testing

### Unit Tests Included

Run tests:

```bash
flutter test lib/features/api_client/tests/
```

### Mock API Calls

```dart
import 'package:http_mock_adapter/http_mock_adapter.dart';

// Create mock adapter
final dio = Dio();
final dioAdapter = DioAdapter(dio: dio);

// Mock GET request
dioAdapter.onGet(
  '/users/1',
  (server) => server.reply(
    200,
    {'id': 1, 'name': 'John Doe'},
  ),
);

// Mock POST request
dioAdapter.onPost(
  '/users',
  (server) => server.reply(
    201,
    {'id': 2, 'name': 'Jane Doe'},
  ),
  data: {'name': 'Jane Doe'},
);

// Mock error
dioAdapter.onGet(
  '/error',
  (server) => server.reply(
    500,
    {'error': 'Internal server error'},
  ),
);
```

---

## Advanced Usage

### Custom Interceptors

```dart
class CustomInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add custom logic before request
    options.headers['X-Custom-Header'] = 'value';
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Custom response handling
    super.onResponse(response, handler);
  }
}

// Add custom interceptor
apiClient.dio.interceptors.add(CustomInterceptor());
```

### Request Cancellation

```dart
// Create cancelToken
final cancelToken = CancelToken();

// Make request with cancelToken
final response = await apiClient.get(
  '/users',
  options: Options(
    extra: {'cancelToken': cancelToken},
  ),
);

// Cancel request
cancelToken.cancel('Request canceled by user');
```

### Disable Retry for Specific Request

```dart
final response = await apiClient.post(
  '/data',
  data: {...},
  options: Options(
    extra: {'disableRetry': true},
  ),
);
```

---

## Best Practices

### 1. Dependency Injection

```dart
// Use provider or similar for DI
class ApiRepository {
  final ApiClient apiClient;

  ApiRepository(this.apiClient);

  Future<List<User>> getUsers() async {
    final response = await apiClient.get<PaginatedResponse<User>>(
      '/users',
      fromJson: (json) => PaginatedResponse<User>.fromJson(
        json,
        (item) => User.fromJson(item),
      ),
    );

    if (!response.success) {
      throw Exception(response.error?.message ?? 'Failed to load users');
    }

    return response.data!.items;
  }
}
```

### 2. Error Handling

Always handle errors:

```dart
try {
  final response = await apiClient.get('/data');

  if (!response.success) {
    // Handle API error
    handleApiError(response.error!);
    return;
  }

  // Process data
  processData(response.data);
} catch (e) {
  // Handle unexpected errors
  print('Unexpected error: $e');
}
```

### 3. Type Safety

Use generic types:

```dart
// Define model
class User {
  final int id;
  final String name;

  User({required this.id, required this.name});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

// Type-safe API call
final response = await apiClient.get<User>(
  '/users/123',
  fromJson: (json) => User.fromJson(json),
);

// response.data is type User?
final User? user = response.data;
```

---

## Troubleshooting

### Token Not Being Added to Requests

Ensure token is saved:

```dart
final isAuthenticated = await apiClient.tokenService.isAuthenticated();
print('Is authenticated: $isAuthenticated');

final token = await apiClient.tokenService.getAccessToken();
print('Current token: $token');
```

### Retry Not Working

Check retry configuration:

```dart
final apiClient = ApiClient(
  config: ApiClientConfig(
    baseUrl: 'https://api.yourapp.com',
    enableRetry: true,  // Must be true
    maxRetries: 3,
    onRefreshToken: () async {
      // Must be implemented for 401 retry
      return await refreshToken();
    },
  ),
);
```

### Certificate Pinning

```dart
// Add certificate pinning to dio instance
apiClient.dio.httpClientAdapter = IOHttpClientAdapter(
  createHttpClient: () {
    final client = HttpClient();
    client.badCertificateCallback = (cert, host, port) {
      // Implement certificate validation
      return cert.sha1.toString() == 'YOUR_CERT_SHA1';
    };
    return client;
  },
);
```

---

## API Reference

See inline documentation in source code for complete API reference.

---

## License

Part of the Reusable Widgets Flutter project.

---

## Support

For issues or questions, please refer to the project documentation or create an issue in the repository.

---

**Module Status**: Production Ready
**Last Updated**: 2025-11-14
**Version**: 1.0.0
