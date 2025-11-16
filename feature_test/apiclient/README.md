# API Client Module

Production-ready HTTP client for Flutter applications using Dio with comprehensive features including authentication, retry logic, pagination, and standardized error handling.

## Features

### Core Capabilities
- **Type-Safe Responses**: Generic wrapper with automatic JSON parsing
- **Interceptor System**: Auth, logging, and retry interceptors
- **Automatic Retry**: Exponential backoff for transient failures
- **Error Handling**: Standardized error responses with categorization
- **Token Management**: Automatic token injection and refresh flow
- **Request/Response Logging**: Debug-friendly logging for development

### HTTP Operations
- **All HTTP Methods**: GET, POST, PUT, PATCH, DELETE
- **File Upload**: Multipart form data with progress tracking
- **File Download**: Download files with progress monitoring
- **Query Parameters**: Easy-to-use query parameter support
- **Custom Headers**: Per-request and default headers

### Advanced Features
- **Pagination Helpers**: Built-in utilities for paginated APIs
- **Timeout Configuration**: Configurable connection, send, and receive timeouts
- **Error Classification**: Network, timeout, auth, validation, and server errors
- **Retry Logic**: Smart retry for retryable errors (network, timeout, 5xx)

## Prerequisites

- Flutter SDK (>=3.4.1 <4.0.0)
- Dart SDK

## Installation

### 1. Navigate to the project directory

```bash
cd feature_test/apiclient
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run the demo application

```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                            # Demo application
└── api_client/
    ├── api_client.dart                  # Main export file
    ├── core/
    │   ├── api_client.dart              # Main API client class
    │   └── api_response.dart            # Response and error models
    ├── services/
    │   └── token_service.dart           # Token storage and management
    ├── interceptors/
    │   ├── auth_interceptor.dart        # Authentication interceptor
    │   ├── retry_interceptor.dart       # Retry logic interceptor
    │   └── logging_interceptor.dart     # Request/response logging
    ├── utils/
    │   └── pagination.dart              # Pagination helpers
    └── tests/
        ├── api_client_test.dart         # Unit tests
        └── pagination_test.dart         # Pagination tests
```

## Quick Start

### Basic Setup

```dart
import 'package:apiclient/api_client/api_client.dart';

// Create configuration
final config = ApiClientConfig(
  baseUrl: 'https://api.yourapp.com',
  connectTimeout: Duration(seconds: 30),
  receiveTimeout: Duration(seconds: 30),
  enableLogging: true,  // Enable in development
  enableRetry: true,
  maxRetries: 3,
);

// Initialize client
final apiClient = ApiClient(config: config);
```

### Making Requests

```dart
// GET request
final response = await apiClient.get<List<Post>>(
  '/posts',
  fromJson: (json) => (json as List)
      .map((item) => Post.fromJson(item))
      .toList(),
);

if (response.success) {
  print('Posts: ${response.data}');
} else {
  print('Error: ${response.error?.message}');
}

// POST request
final createResponse = await apiClient.post(
  '/posts',
  data: {
    'title': 'New Post',
    'body': 'Content here',
    'userId': 1,
  },
);

// PUT request
final updateResponse = await apiClient.put(
  '/posts/1',
  data: {
    'title': 'Updated Title',
    'body': 'Updated content',
  },
);

// DELETE request
final deleteResponse = await apiClient.delete('/posts/1');
```

### With Type Safety

```dart
class Post {
  final int id;
  final String title;
  final String body;

  Post({required this.id, required this.title, required this.body});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }
}

// Type-safe request
final response = await apiClient.get<Post>(
  '/posts/1',
  fromJson: (json) => Post.fromJson(json),
);

if (response.success && response.data != null) {
  final post = response.data!;
  print('Title: ${post.title}');
}
```

## Configuration Options

### API Client Config

```dart
const ApiClientConfig({
  required String baseUrl,             // Base URL for all requests
  Duration connectTimeout,             // Connection timeout (default: 30s)
  Duration receiveTimeout,             // Receive timeout (default: 30s)
  Duration sendTimeout,                // Send timeout (default: 30s)
  bool enableLogging,                  // Enable request/response logging
  bool enableRetry,                    // Enable automatic retry
  int maxRetries,                      // Maximum retry attempts (default: 3)
  Map<String, String>? defaultHeaders, // Headers for all requests
  Function()? onRefreshToken,          // Token refresh callback
});
```

### Examples

```dart
// Development configuration
final devConfig = ApiClientConfig(
  baseUrl: 'https://api-dev.yourapp.com',
  enableLogging: true,
  enableRetry: true,
  maxRetries: 3,
  defaultHeaders: {
    'X-App-Version': '1.0.0',
  },
);

// Production configuration
final prodConfig = ApiClientConfig(
  baseUrl: 'https://api.yourapp.com',
  enableLogging: false,  // Disable in production
  enableRetry: true,
  maxRetries: 2,
  connectTimeout: Duration(seconds: 60),
);
```

## Error Handling

### Error Types

The API client categorizes errors into specific types:

```dart
// Network error (retryable)
ApiError.network(
  message: 'Network connection failed',
);

// Timeout error (retryable)
ApiError.timeout(
  message: 'Request timed out',
);

// Unauthorized (401, not retryable)
ApiError.unauthorized(
  message: 'Authentication required',
);

// Validation error (422, not retryable)
ApiError.validation(
  message: 'Invalid data',
  fieldErrors: {
    'email': ['Email is required'],
    'password': ['Password too short'],
  },
);

// Server error (5xx, retryable)
ApiError.server(
  message: 'Internal server error',
  statusCode: 500,
);

// Not found (404, not retryable)
ApiError.notFound(
  message: 'Resource not found',
);
```

### Handling Errors

```dart
final response = await apiClient.get('/users');

if (response.success) {
  // Handle success
  print('Data: ${response.data}');
} else {
  final error = response.error!;

  // Check error type
  if (error.code == 'UNAUTHORIZED') {
    // Redirect to login
  } else if (error.code == 'VALIDATION_ERROR') {
    // Show validation errors
    error.fieldErrors?.forEach((field, messages) {
      print('$field: ${messages.join(", ")}');
    });
  } else if (error.isRetryable) {
    // Retry was attempted automatically
    print('Failed after ${config.maxRetries} retries');
  }

  // Show error message to user
  showErrorSnackbar(error.message);
}
```

## Authentication

### Token Management

```dart
// Set token
await apiClient.tokenService.setAccessToken('your-jwt-token');

// Get token
final token = await apiClient.tokenService.getAccessToken();

// Clear token (logout)
await apiClient.tokenService.clearTokens();

// Set refresh token
await apiClient.tokenService.setRefreshToken('refresh-token');
```

### Automatic Token Injection

The AuthInterceptor automatically adds the token to all requests:

```dart
// Token is automatically added to header
final response = await apiClient.get('/protected-endpoint');
// Request includes: Authorization: Bearer <token>
```

### Token Refresh

```dart
final config = ApiClientConfig(
  baseUrl: 'https://api.yourapp.com',
  onRefreshToken: () async {
    // Your token refresh logic
    final refreshToken = await apiClient.tokenService.getRefreshToken();

    final response = await http.post(
      'https://api.yourapp.com/auth/refresh',
      body: {'refresh_token': refreshToken},
    );

    final newToken = response.data['access_token'];
    await apiClient.tokenService.setAccessToken(newToken);

    return ApiResponse.success(data: response.data);
  },
);
```

## Interceptors

### Custom Interceptors

```dart
class CustomInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Modify request
    options.headers['X-Custom-Header'] = 'value';
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Process response
    print('Response received: ${response.statusCode}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle errors
    print('Request failed: ${err.message}');
    super.onError(err, handler);
  }
}

// Add to Dio instance
apiClient.dio.interceptors.add(CustomInterceptor());
```

## File Operations

### Upload File

```dart
final response = await apiClient.uploadFile<UploadResponse>(
  '/upload',
  '/path/to/file.jpg',
  fileKey: 'image',
  data: {
    'description': 'Profile picture',
    'category': 'profile',
  },
  onSendProgress: (sent, total) {
    final progress = (sent / total * 100).toStringAsFixed(0);
    print('Upload progress: $progress%');
  },
  fromJson: (json) => UploadResponse.fromJson(json),
);
```

### Download File

```dart
final response = await apiClient.downloadFile(
  '/files/document.pdf',
  '/local/path/document.pdf',
  onReceiveProgress: (received, total) {
    final progress = (received / total * 100).toStringAsFixed(0);
    print('Download progress: $progress%');
  },
);

if (response.success) {
  print('File downloaded successfully');
}
```

## Pagination

### Using Query Parameters

```dart
// Page-based pagination
final response = await apiClient.get(
  '/posts',
  queryParameters: {
    '_page': 1,
    '_limit': 10,
  },
);

// Cursor-based pagination
final response = await apiClient.get(
  '/posts',
  queryParameters: {
    'cursor': 'next_cursor_value',
    'limit': 20,
  },
);
```

### Pagination Helper (if implemented)

```dart
final paginator = Paginator(
  apiClient: apiClient,
  endpoint: '/posts',
  limit: 10,
  fromJson: (json) => Post.fromJson(json),
);

// Fetch first page
await paginator.fetchNextPage();

// Access data
final posts = paginator.items;

// Check if more pages available
if (paginator.hasMore) {
  await paginator.fetchNextPage();
}
```

## Demo Application

The demo app showcases all API client capabilities with an interactive UI:

### Features
- **Overview Tab**: Module capabilities, configuration, and quick actions
- **Requests Tab**: Pre-configured HTTP requests (GET, POST, PUT, DELETE)
- **Features Tab**: Core features, HTTP methods, and error types
- **Logs Tab**: Real-time request/response logging

### Running the Demo

```bash
cd feature_test/apiclient
flutter run
```

### Demo Actions

1. **Sample Requests**: Execute pre-configured API calls to JSONPlaceholder
2. **Test Pagination**: Try paginated requests
3. **Test Error Handling**: See how errors are handled
4. **Change Base URL**: Switch between different API endpoints

## Advanced Usage

### Custom Request Options

```dart
final response = await apiClient.get(
  '/data',
  options: Options(
    headers: {
      'X-Custom-Header': 'value',
    },
    responseType: ResponseType.json,
    followRedirects: false,
    validateStatus: (status) => status! < 500,
  ),
);
```

### Accessing Underlying Dio Instance

```dart
// For advanced Dio features
final dio = apiClient.dio;

// Add custom interceptors
dio.interceptors.add(MyCustomInterceptor());

// Configure transformers
dio.transformer = BackgroundTransformer();
```

### Retry Configuration

The retry interceptor automatically retries failed requests:

```dart
// Retryable errors:
// - Network errors (connection failures)
// - Timeout errors
// - Server errors (5xx)

// Non-retryable errors:
// - Client errors (4xx)
// - Validation errors (422)
// - Unauthorized (401)
```

## Testing

### Unit Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  group('API Client', () {
    late ApiClient apiClient;

    setUp(() {
      apiClient = ApiClient(
        config: ApiClientConfig(
          baseUrl: 'https://api.test.com',
        ),
      );
    });

    test('successful GET request', () async {
      final response = await apiClient.get('/test');

      expect(response.success, isTrue);
      expect(response.data, isNotNull);
    });

    test('handles errors correctly', () async {
      final response = await apiClient.get('/invalid');

      expect(response.success, isFalse);
      expect(response.error, isNotNull);
    });
  });
}
```

### Integration Tests

```dart
void main() {
  testWidgets('API client integration', (tester) async {
    final apiClient = ApiClient(
      config: ApiClientConfig(
        baseUrl: 'https://jsonplaceholder.typicode.com',
      ),
    );

    // Test real API call
    final response = await apiClient.get('/posts/1');

    expect(response.success, isTrue);
    expect(response.data, isNotNull);
  });
}
```

## Troubleshooting

### Issue: Timeout errors
**Solution**:
- Increase timeout duration in config
- Check network connectivity
- Verify API endpoint is accessible

### Issue: Token not added to requests
**Solution**:
- Ensure token is set via tokenService
- Verify AuthInterceptor is added
- Check token is not expired

### Issue: Retry not working
**Solution**:
- Ensure `enableRetry` is true in config
- Check that error is retryable (network, timeout, 5xx)
- Verify maxRetries is > 0

### Issue: JSON parsing errors
**Solution**:
- Verify fromJson function is correct
- Check API response structure matches model
- Enable logging to see raw response

## Performance Tips

1. **Disable Logging in Production**: Set `enableLogging: false`
2. **Use Connection Pooling**: Dio handles this automatically
3. **Cancel Requests**: Cancel unnecessary requests to save bandwidth
4. **Compress Requests**: Enable gzip compression for large payloads
5. **Cache Responses**: Implement caching layer if needed

## Dependencies

- `dio: ^5.4.0` - HTTP client for Dart
- `shared_preferences: ^2.2.2` - Token storage

## Examples

Complete examples are available in:
- `/lib/main.dart` - Interactive demo application
- `/lib/api_client/tests/` - Unit test examples

## Best Practices

1. **Error Handling**: Always check `response.success` before using data
2. **Type Safety**: Use generic types with `fromJson` for type safety
3. **Token Management**: Store tokens securely using tokenService
4. **Logging**: Enable in development, disable in production
5. **Timeout**: Set appropriate timeouts based on API characteristics
6. **Retry Logic**: Let the client handle retries for transient failures

## Roadmap

- [ ] GraphQL support
- [ ] WebSocket connections
- [ ] Request caching layer
- [ ] Offline queue for failed requests
- [ ] Request deduplication
- [ ] Response compression
- [ ] Certificate pinning

## Contributing

This module is part of the Expensize project. For contributions:

1. Follow existing patterns and architecture
2. Add tests for new features
3. Update documentation
4. Ensure backwards compatibility

## License

This is a feature module for the Expensize application.

## Support

For issues or questions about this module, please refer to the main Expensize project documentation or open an issue in the repository.

---

**Built for reliability and developer experience**
