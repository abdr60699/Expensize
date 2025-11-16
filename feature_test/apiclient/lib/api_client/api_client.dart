/// API Client Module for Flutter
///
/// A production-ready, reusable API layer using Dio with comprehensive features
/// including authentication, retry logic, pagination, and standardized error handling.
///
/// ## Features
/// - Automatic token injection and refresh
/// - Standardized error mapping
/// - Retry-on-failure with exponential backoff
/// - Request/response logging
/// - Pagination helpers
/// - File upload/download
/// - Type-safe responses
///
/// ## Quick Start
///
/// ```dart
/// // Initialize
/// final apiClient = ApiClient(
///   config: ApiClientConfig(
///     baseUrl: 'https://api.yourapp.com',
///     onRefreshToken: () async => await refreshToken(),
///   ),
/// );
///
/// // Make request
/// final response = await apiClient.get<User>(
///   '/users/123',
///   fromJson: (json) => User.fromJson(json),
/// );
///
/// // Handle response
/// if (response.success) {
///   print('User: ${response.data?.name}');
/// } else {
///   print('Error: ${response.error?.message}');
/// }
/// ```
///
/// See [README.md](README.md) for complete documentation.
library api_client;

// Core
export 'core/api_client.dart';
export 'core/api_response.dart';

// Services
export 'services/token_service.dart';

// Interceptors
export 'interceptors/auth_interceptor.dart';
export 'interceptors/retry_interceptor.dart';
export 'interceptors/logging_interceptor.dart';

// Utils
export 'utils/pagination.dart';
