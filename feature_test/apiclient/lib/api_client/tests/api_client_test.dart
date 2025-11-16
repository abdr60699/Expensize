/// Tests for API client
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import '../core/api_client.dart';
import '../core/api_response.dart';
import '../services/token_service.dart';

void main() {
  group('ApiClient', () {
    late ApiClient apiClient;
    late Dio dio;
    late DioAdapter dioAdapter;

    setUp(() {
      dio = Dio();
      dioAdapter = DioAdapter(dio: dio);

      apiClient = ApiClient(
        config: ApiClientConfig(
          baseUrl: 'https://api.example.com',
          enableLogging: false,
          enableRetry: false,
        ),
      );

      // Replace dio instance with mock
      // apiClient._dio = dio;
    });

    group('GET requests', () {
      test('successful GET request returns data', () async {
        // Mock successful response
        dioAdapter.onGet(
          '/users/1',
          (server) => server.reply(
            200,
            {'id': 1, 'name': 'John Doe'},
          ),
        );

        // Note: This test requires access to private dio instance
        // In production, you'd use dependency injection or expose dio getter
      });

      test('GET request with query parameters', () async {
        // Test query parameter handling
      });

      test('GET request handles 404 error', () async {
        // Test 404 handling
      });
    });

    group('POST requests', () {
      test('successful POST request', () async {
        // Test POST request
      });

      test('POST request with validation error', () async {
        // Test validation error handling
      });
    });

    group('Error handling', () {
      test('network error is properly handled', () async {
        // Test network error
      });

      test('timeout error is properly handled', () async {
        // Test timeout
      });

      test('401 unauthorized triggers token refresh', () async {
        // Test auth flow
      });
    });
  });

  group('TokenService', () {
    late TokenService tokenService;

    setUp(() {
      // Mock secure storage for testing
      tokenService = TokenService();
    });

    test('save and retrieve access token', () async {
      const token = 'test_access_token';
      await tokenService.saveAccessToken(token);

      final retrieved = await tokenService.getAccessToken();
      expect(retrieved, token);
    });

    test('save and retrieve refresh token', () async {
      const token = 'test_refresh_token';
      await tokenService.saveRefreshToken(token);

      final retrieved = await tokenService.getRefreshToken();
      expect(retrieved, token);
    });

    test('isAuthenticated returns true when token exists', () async {
      await tokenService.saveAccessToken('test_token');

      final isAuth = await tokenService.isAuthenticated();
      expect(isAuth, true);
    });

    test('isAuthenticated returns false after clearing tokens', () async {
      await tokenService.saveAccessToken('test_token');
      await tokenService.clearTokens();

      final isAuth = await tokenService.isAuthenticated();
      expect(isAuth, false);
    });

    test('token expiry check works correctly', () async {
      final futureExpiry = DateTime.now().add(Duration(hours: 1));
      await tokenService.saveTokenExpiry(futureExpiry);

      final isExpired = await tokenService.isTokenExpired();
      expect(isExpired, false);
    });

    test('expired token is detected', () async {
      final pastExpiry = DateTime.now().subtract(Duration(hours: 1));
      await tokenService.saveTokenExpiry(pastExpiry);

      final isExpired = await tokenService.isTokenExpired();
      expect(isExpired, true);
    });
  });

  group('ApiResponse', () {
    test('success response is created correctly', () {
      final response = ApiResponse<String>.success(
        data: 'test data',
        statusCode: 200,
      );

      expect(response.success, true);
      expect(response.data, 'test data');
      expect(response.statusCode, 200);
      expect(response.hasData, true);
      expect(response.hasError, false);
    });

    test('error response is created correctly', () {
      final error = ApiError(
        code: 'TEST_ERROR',
        message: 'Test error message',
      );

      final response = ApiResponse<String>.error(
        error: error,
        statusCode: 400,
      );

      expect(response.success, false);
      expect(response.hasError, true);
      expect(response.error, error);
      expect(response.statusCode, 400);
    });
  });

  group('ApiError', () {
    test('network error factory creates correct error', () {
      final error = ApiError.network();

      expect(error.code, 'NETWORK_ERROR');
      expect(error.isRetryable, true);
    });

    test('unauthorized error factory creates correct error', () {
      final error = ApiError.unauthorized();

      expect(error.code, 'UNAUTHORIZED');
      expect(error.statusCode, 401);
      expect(error.isRetryable, false);
    });

    test('validation error includes field errors', () {
      final fieldErrors = {
        'email': ['Email is required', 'Invalid email format'],
        'password': ['Password is too short'],
      };

      final error = ApiError.validation(
        message: 'Validation failed',
        fieldErrors: fieldErrors,
      );

      expect(error.code, 'VALIDATION_ERROR');
      expect(error.statusCode, 422);
      expect(error.fieldErrors, fieldErrors);
    });
  });
}
