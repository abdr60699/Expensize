/// Main API client using Dio
library;

import 'package:dio/dio.dart';
import '../interceptors/auth_interceptor.dart';
import '../interceptors/retry_interceptor.dart';
import '../interceptors/logging_interceptor.dart';
import '../services/token_service.dart';
import 'api_response.dart';

/// Configuration for API client
class ApiClientConfig {
  /// Base URL for API
  final String baseUrl;

  /// Connection timeout
  final Duration connectTimeout;

  /// Receive timeout
  final Duration receiveTimeout;

  /// Send timeout
  final Duration sendTimeout;

  /// Enable logging
  final bool enableLogging;

  /// Enable retry on failure
  final bool enableRetry;

  /// Maximum retry attempts
  final int maxRetries;

  /// Custom headers to include in all requests
  final Map<String, String>? defaultHeaders;

  /// Callback for token refresh
  final Future<ApiResponse<Map<String, dynamic>>> Function()? onRefreshToken;

  const ApiClientConfig({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
    this.enableLogging = true,
    this.enableRetry = true,
    this.maxRetries = 3,
    this.defaultHeaders,
    this.onRefreshToken,
  });
}

/// Main API client
class ApiClient {
  late final Dio _dio;
  final ApiClientConfig config;
  final TokenService tokenService;

  ApiClient({
    required this.config,
    TokenService? tokenService,
  }) : tokenService = tokenService ?? TokenService() {
    _initializeDio();
  }

  /// Initialize Dio with configuration and interceptors
  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: config.connectTimeout,
        receiveTimeout: config.receiveTimeout,
        sendTimeout: config.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ...?config.defaultHeaders,
        },
      ),
    );

    // Add interceptors in order
    if (config.enableLogging) {
      _dio.interceptors.add(LoggingInterceptor());
    }

    _dio.interceptors.add(AuthInterceptor(tokenService));

    if (config.enableRetry) {
      _dio.interceptors.add(
        RetryInterceptor(
          tokenService: tokenService,
          dio: _dio,
          onRefreshToken: config.onRefreshToken,
          maxRetries: config.maxRetries,
        ),
      );
    }
  }

  /// GET request
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e, stackTrace) {
      return ApiResponse.error(
        error: ApiError.unknown(
          message: e.toString(),
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// POST request
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e, stackTrace) {
      return ApiResponse.error(
        error: ApiError.unknown(
          message: e.toString(),
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// PUT request
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e, stackTrace) {
      return ApiResponse.error(
        error: ApiError.unknown(
          message: e.toString(),
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// PATCH request
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e, stackTrace) {
      return ApiResponse.error(
        error: ApiError.unknown(
          message: e.toString(),
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// DELETE request
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e, stackTrace) {
      return ApiResponse.error(
        error: ApiError.unknown(
          message: e.toString(),
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Upload file
  Future<ApiResponse<T>> uploadFile<T>(
    String path,
    String filePath, {
    String fileKey = 'file',
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        fileKey: await MultipartFile.fromFile(filePath, filename: fileName),
        ...?data,
      });

      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e, stackTrace) {
      return ApiResponse.error(
        error: ApiError.unknown(
          message: e.toString(),
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Download file
  Future<ApiResponse<void>> downloadFile(
    String path,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      await _dio.download(
        path,
        savePath,
        queryParameters: queryParameters,
        onReceiveProgress: onReceiveProgress,
      );

      return ApiResponse.success();
    } on DioException catch (e) {
      return _handleError<void>(e);
    } catch (e, stackTrace) {
      return ApiResponse.error(
        error: ApiError.unknown(
          message: e.toString(),
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Handle successful response
  ApiResponse<T> _handleResponse<T>(
    Response response,
    T Function(dynamic)? fromJson,
  ) {
    // Parse response data
    T? data;
    if (fromJson != null && response.data != null) {
      try {
        data = fromJson(response.data);
      } catch (e) {
        return ApiResponse.error(
          error: ApiError(
            code: 'PARSE_ERROR',
            message: 'Failed to parse response: $e',
            statusCode: response.statusCode,
          ),
        );
      }
    } else {
      data = response.data as T?;
    }

    return ApiResponse.success(
      data: data,
      statusCode: response.statusCode,
      message: response.statusMessage,
    );
  }

  /// Handle error response
  ApiResponse<T> _handleError<T>(DioException error) {
    ApiError apiError;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        apiError = ApiError.timeout(
          message: 'Request timed out. Please try again.',
        );
        break;

      case DioExceptionType.connectionError:
        apiError = ApiError.network(
          message: 'Network connection failed. Please check your internet.',
          originalError: error,
          stackTrace: error.stackTrace,
        );
        break;

      case DioExceptionType.badResponse:
        apiError = _parseErrorResponse(error.response);
        break;

      case DioExceptionType.cancel:
        apiError = ApiError(
          code: 'REQUEST_CANCELED',
          message: 'Request was canceled',
          statusCode: error.response?.statusCode,
        );
        break;

      default:
        apiError = ApiError.unknown(
          message: error.message ?? 'An unknown error occurred',
          originalError: error,
          stackTrace: error.stackTrace,
        );
    }

    return ApiResponse.error(
      error: apiError,
      statusCode: error.response?.statusCode,
    );
  }

  /// Parse error response from server
  ApiError _parseErrorResponse(Response? response) {
    if (response == null) {
      return ApiError.unknown(message: 'No response from server');
    }

    final statusCode = response.statusCode ?? 500;
    final data = response.data;

    // Try to extract error message from response
    String message = 'Request failed';
    String? details;
    Map<String, List<String>>? fieldErrors;

    if (data is Map<String, dynamic>) {
      message = data['message'] ?? data['error'] ?? message;
      details = data['details']?.toString();

      // Parse field errors (for validation errors)
      if (data['errors'] is Map) {
        fieldErrors = {};
        (data['errors'] as Map).forEach((key, value) {
          if (value is List) {
            fieldErrors![key.toString()] =
                value.map((e) => e.toString()).toList();
          } else {
            fieldErrors![key.toString()] = [value.toString()];
          }
        });
      }
    } else if (data is String) {
      message = data;
    }

    // Categorize error by status code
    if (statusCode == 401) {
      return ApiError.unauthorized(message: message);
    } else if (statusCode == 404) {
      return ApiError.notFound(message: message);
    } else if (statusCode == 422) {
      return ApiError.validation(
        message: message,
        fieldErrors: fieldErrors,
      );
    } else if (statusCode >= 500) {
      return ApiError.server(
        message: message,
        statusCode: statusCode,
      );
    }

    return ApiError(
      code: 'HTTP_$statusCode',
      message: message,
      details: details,
      fieldErrors: fieldErrors,
      statusCode: statusCode,
      isRetryable: statusCode >= 500,
    );
  }

  /// Get underlying Dio instance (for advanced use cases)
  Dio get dio => _dio;
}
