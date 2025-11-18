# API Client Features

Complete guide to all features and capabilities available in the API Client module.

## Table of Contents

- [HTTP Methods](#http-methods)
- [Authentication](#authentication)
- [Error Handling](#error-handling)
- [Retry Logic](#retry-logic)
- [Pagination](#pagination)
- [File Operations](#file-operations)
- [Interceptors](#interceptors)
- [Type Safety](#type-safety)

---

## HTTP Methods

Comprehensive HTTP client built on Dio with standardized responses.

### GET Requests

Retrieve data from the server.

**What you can do:**
- Fetch single resources
- List resources with filters
- Query with parameters
- Type-safe responses
- Automatic deserialization

**Example - Simple GET:**
```dart
final response = await apiClient.get<User>(
  '/users/123',
  fromJson: (json) => User.fromJson(json),
);

if (response.success) {
  print('User: ${response.data?.name}');
} else {
  print('Error: ${response.error?.message}');
}
```

**Example - GET with Query Parameters:**
```dart
final response = await apiClient.get<List<Product>>(
  '/products',
  queryParameters: {
    'category': 'electronics',
    'minPrice': 100,
    'maxPrice': 500,
    'sort': 'price_asc',
  },
  fromJson: (json) => (json as List)
      .map((item) => Product.fromJson(item))
      .toList(),
);

if (response.success && response.data != null) {
  for (final product in response.data!) {
    print('${product.name}: \$${product.price}');
  }
}
```

---

### POST Requests

Create new resources or submit data.

**What you can do:**
- Create new resources
- Submit forms
- Send JSON data
- Receive typed responses
- Handle validation errors

**Example - Create Resource:**
```dart
final response = await apiClient.post<User>(
  '/users',
  data: {
    'name': 'John Doe',
    'email': 'john@example.com',
    'password': 'secret123',
  },
  fromJson: (json) => User.fromJson(json),
);

if (response.success) {
  print('User created: ${response.data?.id}');
} else if (response.error?.code == 'VALIDATION_ERROR') {
  // Handle validation errors
  response.error?.fieldErrors?.forEach((field, errors) {
    print('$field: ${errors.join(', ')}');
  });
}
```

**Example - Login:**
```dart
final response = await apiClient.post<AuthToken>(
  '/auth/login',
  data: {
    'email': email,
    'password': password,
  },
  fromJson: (json) => AuthToken.fromJson(json),
);

if (response.success && response.data != null) {
  // Save token
  await tokenService.saveToken(response.data!.token);
  print('Login successful');
} else {
  print('Login failed: ${response.error?.message}');
}
```

---

### PUT Requests

Update entire resources.

**Example:**
```dart
final response = await apiClient.put<User>(
  '/users/123',
  data: {
    'name': 'Jane Doe',
    'email': 'jane@example.com',
    'bio': 'Software developer',
  },
  fromJson: (json) => User.fromJson(json),
);

if (response.success) {
  print('User updated successfully');
}
```

---

### PATCH Requests

Partially update resources.

**Example:**
```dart
final response = await apiClient.patch<User>(
  '/users/123',
  data: {
    'bio': 'Updated bio text',
  },
  fromJson: (json) => User.fromJson(json),
);
```

---

### DELETE Requests

Remove resources.

**Example:**
```dart
final response = await apiClient.delete(
  '/users/123',
);

if (response.success) {
  print('User deleted successfully');
} else {
  print('Delete failed: ${response.error?.message}');
}
```

---

## Authentication

Automatic token injection and refresh.

### Token Management

**What you can do:**
- Automatic token injection in headers
- Token refresh on 401 errors
- Secure token storage
- Multiple token types (Bearer, API Key, etc.)
- Skip auth for specific endpoints

**Features:**
- TokenService for managing tokens
- AuthInterceptor for automatic injection
- Automatic refresh on expiry
- Skip auth for login/register endpoints

**Example - Save Token:**
```dart
// After successful login
await tokenService.saveToken('your_access_token');
await tokenService.saveRefreshToken('your_refresh_token');

// All subsequent requests automatically include token
final response = await apiClient.get<Profile>(
  '/profile',
  fromJson: (json) => Profile.fromJson(json),
);
```

**Example - Skip Auth for Specific Request:**
```dart
final response = await apiClient.get<AppConfig>(
  '/config/public',
  options: Options(extra: {'skipAuth': true}),
  fromJson: (json) => AppConfig.fromJson(json),
);
```

---

### Token Refresh

Automatic token refresh when receiving 401 errors.

**Configuration:**
```dart
final apiClient = ApiClient(
  config: ApiClientConfig(
    baseUrl: 'https://api.yourapp.com',
    onRefreshToken: () async {
      // Implement your token refresh logic
      final refreshToken = await tokenService.getRefreshToken();

      final response = await dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final newToken = response.data['access_token'];
        final newRefreshToken = response.data['refresh_token'];

        await tokenService.saveToken(newToken);
        await tokenService.saveRefreshToken(newRefreshToken);

        return ApiResponse.success(data: response.data);
      }

      return ApiResponse.error(
        error: ApiError.unauthorized(message: 'Token refresh failed'),
      );
    },
  ),
);
```

**What happens:**
1. Request fails with 401 Unauthorized
2. RetryInterceptor detects 401
3. Calls `onRefreshToken` callback
4. Saves new tokens
5. Retries original request with new token
6. Returns result to caller

---

## Error Handling

Comprehensive error handling with categorized error types.

### Error Types

**Network Errors:**
- Connection failed
- DNS lookup failed
- No internet connection

**Timeout Errors:**
- Connection timeout
- Receive timeout
- Send timeout

**HTTP Errors:**
- 400 Bad Request
- 401 Unauthorized
- 403 Forbidden
- 404 Not Found
- 422 Validation Error
- 500+ Server Errors

**Example - Handle Different Error Types:**
```dart
final response = await apiClient.get<User>('/users/123');

if (!response.success && response.error != null) {
  final error = response.error!;

  switch (error.code) {
    case 'NETWORK_ERROR':
      showSnackbar('No internet connection');
      break;

    case 'TIMEOUT':
      showSnackbar('Request timed out. Please try again.');
      break;

    case 'UNAUTHORIZED':
      // Redirect to login
      Navigator.pushReplacementNamed(context, '/login');
      break;

    case 'NOT_FOUND':
      showSnackbar('User not found');
      break;

    case 'VALIDATION_ERROR':
      // Show field-specific errors
      error.fieldErrors?.forEach((field, errors) {
        showFieldError(field, errors.first);
      });
      break;

    case 'SERVER_ERROR':
      showSnackbar('Server error. Please try again later.');
      break;

    default:
      showSnackbar(error.message);
  }
}
```

---

### Validation Errors

Special handling for form validation errors.

**Server Response Example:**
```json
{
  "message": "Validation failed",
  "errors": {
    "email": ["Email is required", "Email must be valid"],
    "password": ["Password must be at least 8 characters"],
    "age": ["Age must be between 18 and 100"]
  }
}
```

**Handling:**
```dart
final response = await apiClient.post<User>(
  '/users',
  data: userData,
);

if (response.error?.code == 'VALIDATION_ERROR') {
  final fieldErrors = response.error?.fieldErrors;

  // Display errors next to form fields
  setState(() {
    emailError = fieldErrors?['email']?.first;
    passwordError = fieldErrors?['password']?.first;
    ageError = fieldErrors?['age']?.first;
  });
}
```

---

### Retryable Errors

Automatic retry for transient failures.

**Automatically Retryable:**
- Network errors
- Timeout errors
- 500+ Server errors
- Rate limit errors (429)

**Not Retryable:**
- 400 Bad Request
- 401 Unauthorized
- 404 Not Found
- 422 Validation Error

**Example - Check if Retryable:**
```dart
if (response.error?.isRetryable == true) {
  // Show retry button
  showRetryButton(() async {
    await retryRequest();
  });
} else {
  // Show error message only
  showError(response.error?.message);
}
```

---

## Retry Logic

Automatic retry with exponential backoff.

### Retry Configuration

**Features:**
- Configurable max retries (default: 3)
- Exponential backoff
- Automatic for retryable errors
- Respects retry-after header

**Configuration:**
```dart
final apiClient = ApiClient(
  config: ApiClientConfig(
    baseUrl: 'https://api.yourapp.com',
    enableRetry: true,
    maxRetries: 3, // Try up to 3 times
  ),
);
```

### How Retry Works

**Retry Delays:**
- 1st retry: 1 second delay
- 2nd retry: 2 seconds delay
- 3rd retry: 4 seconds delay
- Exponential: 2^attempt seconds

**Example Scenario:**
```dart
// First attempt: Network error
// Wait 1 second
// Retry 1: Network error
// Wait 2 seconds
// Retry 2: Network error
// Wait 4 seconds
// Retry 3: Success!

final response = await apiClient.get<Data>('/data');
// Returns result from successful retry
```

**Logged Output:**
```
[ApiClient] GET /data
[ApiClient] Network error, retrying (1/3)...
[ApiClient] Network error, retrying (2/3)...
[ApiClient] Network error, retrying (3/3)...
[ApiClient] Success on retry 3
```

---

## Pagination

Comprehensive pagination support with helpers.

### Pagination Parameters

Control page, size, sorting, and filtering.

**Example:**
```dart
final params = PaginationParams(
  page: 1,
  pageSize: 20,
  sortBy: 'created_at',
  sortDirection: 'desc',
  search: 'flutter',
  filters: {
    'category': 'mobile',
    'minPrice': 100,
  },
);

// Convert to query parameters
final queryParams = params.toQueryParams();
// {page: 1, pageSize: 20, sortBy: 'created_at', sortDirection: 'desc', search: 'flutter', category: 'mobile', minPrice: 100}

final response = await apiClient.get<PaginatedResponse<Product>>(
  '/products',
  queryParameters: queryParams,
  fromJson: (json) => PaginatedResponse.fromJson(
    json,
    (item) => Product.fromJson(item),
  ),
);
```

---

### Paginated Response

Structured response with metadata.

**Response Format:**
```json
{
  "items": [...],
  "currentPage": 1,
  "totalPages": 10,
  "totalItems": 193,
  "pageSize": 20
}
```

**Usage:**
```dart
final paginatedResponse = response.data!;

print('Showing ${paginatedResponse.itemCount} items');
print('Page ${paginatedResponse.currentPage} of ${paginatedResponse.totalPages}');
print('Total: ${paginatedResponse.totalItems} items');

if (paginatedResponse.hasNext) {
  print('Load next page...');
}

if (paginatedResponse.hasPrevious) {
  print('Go to previous page...');
}
```

---

### Pagination Controller

Manage paginated lists with automatic loading.

**Example - Infinite Scroll:**
```dart
class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late PaginationController<Product> _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Create pagination controller
    _controller = PaginationController<Product>(
      fetchData: (params) async {
        final response = await apiClient.get<PaginatedResponse<Product>>(
          '/products',
          queryParameters: params.toQueryParams(),
          fromJson: (json) => PaginatedResponse.fromJson(
            json,
            (item) => Product.fromJson(item),
          ),
        );

        return response.data!;
      },
    );

    // Load first page
    _controller.loadFirstPage();

    // Setup infinite scroll
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent * 0.8) {
        // 80% scrolled, load next page
        _controller.loadNextPage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products (${_controller.totalCount})'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => _controller.refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(8),
            child: TextField(
              onSubmitted: (query) => _controller.search(query),
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),

          // Product list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _controller.allItems.length +
                  (_controller.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _controller.allItems.length) {
                  // Loading indicator
                  return Center(child: CircularProgressIndicator());
                }

                final product = _controller.allItems[index];
                return ProductTile(product: product);
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

### Pagination Navigation

Navigate between pages.

**Example:**
```dart
// Next page
params = params.nextPage();

// Previous page
params = params.previousPage();

// Reset to first page
params = params.resetToFirstPage();

// Go to specific page
params = params.copyWith(page: 5);
```

---

## File Operations

Upload and download files with progress tracking.

### File Upload

Upload files with multipart/form-data.

**Example - Upload Single File:**
```dart
final response = await apiClient.uploadFile<UploadResult>(
  '/upload',
  filePath: '/path/to/image.jpg',
  fileKey: 'photo',
  data: {
    'title': 'Profile Picture',
    'category': 'avatar',
  },
  onSendProgress: (sent, total) {
    final progress = (sent / total * 100).toStringAsFixed(0);
    print('Upload progress: $progress%');
  },
  fromJson: (json) => UploadResult.fromJson(json),
);

if (response.success) {
  print('File uploaded: ${response.data?.url}');
}
```

**Example - Upload with Progress UI:**
```dart
class FileUploadWidget extends StatefulWidget {
  @override
  _FileUploadWidgetState createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  double _uploadProgress = 0.0;
  bool _uploading = false;

  Future<void> _uploadFile(String filePath) async {
    setState(() {
      _uploading = true;
      _uploadProgress = 0.0;
    });

    final response = await apiClient.uploadFile(
      '/upload',
      filePath,
      onSendProgress: (sent, total) {
        setState(() {
          _uploadProgress = sent / total;
        });
      },
    );

    setState(() => _uploading = false);

    if (response.success) {
      showSuccessDialog();
    } else {
      showErrorDialog(response.error?.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _uploading ? null : () => _pickAndUpload(),
          child: Text('Upload File'),
        ),
        if (_uploading)
          LinearProgressIndicator(value: _uploadProgress),
      ],
    );
  }
}
```

---

### File Download

Download files with progress tracking.

**Example:**
```dart
final response = await apiClient.downloadFile(
  '/files/document.pdf',
  '/local/path/document.pdf',
  onReceiveProgress: (received, total) {
    if (total != -1) {
      final progress = (received / total * 100).toStringAsFixed(0);
      print('Download progress: $progress%');
    }
  },
);

if (response.success) {
  print('File downloaded successfully');
  // Open the file
  await OpenFile.open('/local/path/document.pdf');
}
```

---

## Interceptors

Powerful request/response interceptors.

### Logging Interceptor

Log all requests and responses for debugging.

**What it logs:**
- Request method, URL, headers, body
- Response status, headers, body
- Errors and stack traces
- Timing information

**Example Output:**
```
[ApiClient] → GET https://api.example.com/users/123
[ApiClient] Headers: {Authorization: Bearer xxx, Content-Type: application/json}
[ApiClient] ← 200 OK (234ms)
[ApiClient] Response: {"id": 123, "name": "John Doe"}
```

**Configuration:**
```dart
final apiClient = ApiClient(
  config: ApiClientConfig(
    baseUrl: 'https://api.example.com',
    enableLogging: true, // Enable in debug mode
  ),
);
```

---

### Auth Interceptor

Automatically inject authentication tokens.

**Features:**
- Automatic Bearer token injection
- Skip auth for login/register endpoints
- Custom auth header support
- Per-request auth override

**Skip Auth:**
```dart
// Automatically skipped for these paths:
// - /auth/login
// - /auth/register
// - /auth/refresh
// - /auth/forgot-password

// Manual skip for specific request:
final response = await apiClient.get(
  '/public/data',
  options: Options(extra: {'skipAuth': true}),
);
```

---

### Retry Interceptor

Automatically retry failed requests.

**Features:**
- Exponential backoff
- Configurable max retries
- Automatic token refresh on 401
- Respects retry-after header
- Only retries safe methods (GET, PUT, DELETE)

---

### Custom Interceptors

Add your own interceptors.

**Example:**
```dart
class CustomHeaderInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    // Add custom headers
    options.headers['X-App-Version'] = '1.0.0';
    options.headers['X-Platform'] = Platform.operatingSystem;
    options.headers['X-Device-Id'] = deviceId;

    handler.next(options);
  }
}

// Add to Dio
final dio = apiClient.dio;
dio.interceptors.add(CustomHeaderInterceptor());
```

---

## Type Safety

Strongly typed requests and responses.

### Type-Safe Responses

**Example:**
```dart
// Define your model
class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}

// Make typed request
final response = await apiClient.get<User>(
  '/users/123',
  fromJson: (json) => User.fromJson(json),
);

// Type-safe access
if (response.success && response.data != null) {
  final user = response.data!; // User type
  print(user.name); // Type-safe
}
```

---

### Generic Lists

**Example:**
```dart
final response = await apiClient.get<List<Product>>(
  '/products',
  fromJson: (json) {
    return (json as List)
        .map((item) => Product.fromJson(item))
        .toList();
  },
);

if (response.success && response.data != null) {
  for (final product in response.data!) {
    print(product.name);
  }
}
```

---

### Nested Objects

**Example:**
```dart
class Order {
  final int id;
  final User customer;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.customer,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      customer: User.fromJson(json['customer']),
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
    );
  }
}

final response = await apiClient.get<Order>(
  '/orders/456',
  fromJson: (json) => Order.fromJson(json),
);
```

---

## Advanced Features

### Custom Headers

**Per-Request:**
```dart
final response = await apiClient.get(
  '/data',
  options: Options(
    headers: {
      'X-Custom-Header': 'value',
      'X-Request-Id': requestId,
    },
  ),
);
```

**Default Headers:**
```dart
final apiClient = ApiClient(
  config: ApiClientConfig(
    baseUrl: 'https://api.example.com',
    defaultHeaders: {
      'X-App-Version': '1.0.0',
      'X-Platform': 'mobile',
    },
  ),
);
```

---

### Timeout Configuration

```dart
final apiClient = ApiClient(
  config: ApiClientConfig(
    baseUrl: 'https://api.example.com',
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 30),
    sendTimeout: Duration(seconds: 30),
  ),
);
```

---

### Response Metadata

```dart
final response = await apiClient.get<User>('/users/123');

print('Status: ${response.statusCode}');
print('Message: ${response.message}');
print('Success: ${response.success}');
print('Has Data: ${response.hasData}');
print('Has Error: ${response.hasError}');
print('Timestamp: ${response.timestamp}');
```

---

## Summary

The API Client module provides:

✅ **HTTP Methods**: GET, POST, PUT, PATCH, DELETE
✅ **Authentication**: Automatic token injection and refresh
✅ **Error Handling**: Categorized errors with field validation
✅ **Retry Logic**: Exponential backoff for transient failures
✅ **Pagination**: Complete pagination support with controller
✅ **File Operations**: Upload/download with progress tracking
✅ **Interceptors**: Logging, auth, retry, and custom
✅ **Type Safety**: Strongly typed requests and responses
✅ **Configurable**: Timeouts, retries, headers, logging
✅ **Production-Ready**: Battle-tested, reliable, performant

All designed to make API integration simple, type-safe, and reliable.
