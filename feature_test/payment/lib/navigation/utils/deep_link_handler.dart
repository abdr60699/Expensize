import 'dart:async';
import 'package:flutter/services.dart';
import '../models/app_route.dart';
import '../services/navigation_service.dart';

/// Handles deep links and universal links
class DeepLinkHandler {
  /// The navigation service to use for navigation
  final NavigationService navigationService;

  /// Available routes
  final List<AppRoute> routes;

  /// Stream of incoming deep links
  final StreamController<Uri> _deepLinkController =
      StreamController<Uri>.broadcast();

  /// Getter for deep link stream
  Stream<Uri> get deepLinkStream => _deepLinkController.stream;

  /// Method channel for deep links
  static const MethodChannel _channel =
      MethodChannel('app/deep_links');

  DeepLinkHandler({
    required this.navigationService,
    required this.routes,
  });

  /// Initializes the deep link handler
  Future<void> initialize() async {
    // Listen for deep links while app is running
    _channel.setMethodCallHandler(_handleMethodCall);

    // Get the initial link (if app was opened via deep link)
    try {
      final String? initialLink = await _channel.invokeMethod('getInitialLink');
      if (initialLink != null) {
        final uri = Uri.parse(initialLink);
        await handleDeepLink(uri);
      }
    } catch (e) {
      // Handle error - likely platform doesn't support initial links
    }
  }

  /// Handles method calls from platform
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'handleDeepLink') {
      final String link = call.arguments as String;
      final uri = Uri.parse(link);
      _deepLinkController.add(uri);
      await handleDeepLink(uri);
    }
  }

  /// Handles a deep link URI
  Future<void> handleDeepLink(Uri uri) async {
    // Extract path and query parameters
    final path = uri.path;
    final queryParams = uri.queryParameters;

    // Find matching route
    final routeName = _findRouteByPath(path);
    if (routeName == null) {
      // No matching route found
      return;
    }

    // Navigate to the route
    await navigationService.navigateTo(
      routeName,
      queryParams: queryParams,
    );
  }

  /// Finds a route by its path
  String? _findRouteByPath(String path) {
    AppRoute? findRecursive(List<AppRoute> routes) {
      for (final route in routes) {
        if (route.path == path) {
          return route;
        }
        if (route.children.isNotEmpty) {
          final found = findRecursive(route.children);
          if (found != null) return found;
        }
      }
      return null;
    }

    final route = findRecursive(routes);
    return route?.name;
  }

  /// Disposes resources
  void dispose() {
    _deepLinkController.close();
  }

  /// Creates a deep link URL for a given route
  String createDeepLink({
    required String scheme,
    required String host,
    required String routePath,
    Map<String, String>? queryParams,
  }) {
    final uri = Uri(
      scheme: scheme,
      host: host,
      path: routePath,
      queryParameters: queryParams?.isNotEmpty == true ? queryParams : null,
    );
    return uri.toString();
  }

  /// Parses a deep link URL
  DeepLinkData? parseDeepLink(String url) {
    try {
      final uri = Uri.parse(url);
      return DeepLinkData(
        scheme: uri.scheme,
        host: uri.host,
        path: uri.path,
        queryParameters: uri.queryParameters,
      );
    } catch (e) {
      return null;
    }
  }
}

/// Data extracted from a deep link
class DeepLinkData {
  final String scheme;
  final String host;
  final String path;
  final Map<String, String> queryParameters;

  const DeepLinkData({
    required this.scheme,
    required this.host,
    required this.path,
    required this.queryParameters,
  });

  @override
  String toString() {
    return 'DeepLinkData(scheme: $scheme, host: $host, '
        'path: $path, queryParams: $queryParameters)';
  }
}
