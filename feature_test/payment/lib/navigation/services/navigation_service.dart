import 'package:flutter/material.dart';
import '../models/app_route.dart';
import '../models/navigation_result.dart';
import '../models/route_match.dart';
import '../utils/route_matcher.dart';

/// Service for programmatic navigation throughout the app
/// Provides a clean, imperative API on top of Navigator 2.0
class NavigationService {
  /// Global navigator key
  final GlobalKey<NavigatorState> navigatorKey;

  /// All available routes
  final List<AppRoute> routes;

  /// Navigation history for tracking
  final List<String> _history = [];

  NavigationService({
    required this.navigatorKey,
    required this.routes,
  });

  /// Gets the current BuildContext
  BuildContext? get context => navigatorKey.currentContext;

  /// Gets the current state
  NavigatorState? get navigator => navigatorKey.currentState;

  /// Navigation history
  List<String> get history => List.unmodifiable(_history);

  /// Navigates to a named route
  Future<NavigationResult<T>> navigateTo<T>(
    String routeName, {
    Map<String, dynamic>? pathParams,
    Map<String, String>? queryParams,
    Object? arguments,
  }) async {
    final route = _findRouteByName(routeName);
    if (route == null) {
      return NavigationResult.failure('Route not found: $routeName');
    }

    if (navigator == null) {
      return NavigationResult.failure('Navigator not initialized');
    }

    try {
      // Build the path
      final path = RouteMatcher.buildPath(
        route,
        pathParams ?? {},
        queryParams: queryParams,
      );

      _addToHistory(path);

      // Navigate using the path
      final result = await navigator!.pushNamed(
        path,
        arguments: arguments,
      );

      return NavigationResult.success(
        data: result as T?,
        routeName: routeName,
      );
    } catch (e) {
      return NavigationResult.failure('Navigation failed: $e');
    }
  }

  /// Pushes a new route and removes all previous routes
  Future<NavigationResult<T>> navigateAndRemoveUntil<T>(
    String routeName, {
    Map<String, dynamic>? pathParams,
    Map<String, String>? queryParams,
    bool Function(Route<dynamic>)? predicate,
  }) async {
    final route = _findRouteByName(routeName);
    if (route == null) {
      return NavigationResult.failure('Route not found: $routeName');
    }

    if (navigator == null) {
      return NavigationResult.failure('Navigator not initialized');
    }

    try {
      final path = RouteMatcher.buildPath(
        route,
        pathParams ?? {},
        queryParams: queryParams,
      );

      _clearHistory();
      _addToHistory(path);

      final result = await navigator!.pushNamedAndRemoveUntil(
        path,
        predicate ?? (route) => false,
      );

      return NavigationResult.success(
        data: result as T?,
        routeName: routeName,
      );
    } catch (e) {
      return NavigationResult.failure('Navigation failed: $e');
    }
  }

  /// Replaces the current route
  Future<NavigationResult<T>> replace<T>(
    String routeName, {
    Map<String, dynamic>? pathParams,
    Map<String, String>? queryParams,
    Object? arguments,
  }) async {
    final route = _findRouteByName(routeName);
    if (route == null) {
      return NavigationResult.failure('Route not found: $routeName');
    }

    if (navigator == null) {
      return NavigationResult.failure('Navigator not initialized');
    }

    try {
      final path = RouteMatcher.buildPath(
        route,
        pathParams ?? {},
        queryParams: queryParams,
      );

      if (_history.isNotEmpty) {
        _history.removeLast();
      }
      _addToHistory(path);

      final result = await navigator!.pushReplacementNamed(
        path,
        arguments: arguments,
      );

      return NavigationResult.success(
        data: result as T?,
        routeName: routeName,
      );
    } catch (e) {
      return NavigationResult.failure('Navigation failed: $e');
    }
  }

  /// Pops the current route
  void pop<T>([T? result]) {
    if (navigator?.canPop() ?? false) {
      if (_history.isNotEmpty) {
        _history.removeLast();
      }
      navigator!.pop(result);
    }
  }

  /// Pops until a specific route
  void popUntil(String routeName) {
    final route = _findRouteByName(routeName);
    if (route == null) return;

    navigator?.popUntil((route) {
      return route.settings.name == routeName;
    });

    // Clean up history
    while (_history.isNotEmpty && !_history.last.contains(routeName)) {
      _history.removeLast();
    }
  }

  /// Checks if we can pop
  bool canPop() {
    return navigator?.canPop() ?? false;
  }

  /// Pops until root
  void popToRoot() {
    navigator?.popUntil((route) => route.isFirst);
    _clearHistory();
  }

  /// Shows a dialog
  Future<T?> showDialog<T>({
    required Widget Function(BuildContext) builder,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
  }) async {
    if (context == null) return null;

    return await showDialog<T>(
      context: context!,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      builder: builder,
    );
  }

  /// Shows a bottom sheet
  Future<T?> showBottomSheet<T>({
    required Widget Function(BuildContext) builder,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
  }) async {
    if (context == null) return null;

    return await showModalBottomSheet<T>(
      context: context!,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor,
      builder: builder,
    );
  }

  /// Shows a snackbar
  void showSnackBar({
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    if (context == null) return;

    ScaffoldMessenger.of(context!).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
      ),
    );
  }

  /// Navigates with custom page route
  Future<T?> navigateWithCustomRoute<T>(Route<T> route) async {
    if (navigator == null) return null;
    return await navigator!.push(route);
  }

  /// Builds a route match for a given route name
  RouteMatch? buildRouteMatch(
    String routeName, {
    Map<String, dynamic>? pathParams,
    Map<String, String>? queryParams,
  }) {
    final route = _findRouteByName(routeName);
    if (route == null) return null;

    final path = RouteMatcher.buildPath(
      route,
      pathParams ?? {},
      queryParams: queryParams,
    );

    return RouteMatch(
      route: route,
      pathParameters: pathParams ?? {},
      queryParameters: queryParams ?? {},
      matchedPath: path,
    );
  }

  /// Finds a route by name
  AppRoute? _findRouteByName(String name) {
    AppRoute? findRecursive(List<AppRoute> routes) {
      for (final route in routes) {
        if (route.name == name) {
          return route;
        }
        if (route.children.isNotEmpty) {
          final found = findRecursive(route.children);
          if (found != null) return found;
        }
      }
      return null;
    }

    return findRecursive(routes);
  }

  /// Adds a path to navigation history
  void _addToHistory(String path) {
    _history.add(path);
    // Keep history size reasonable (last 50 entries)
    if (_history.length > 50) {
      _history.removeAt(0);
    }
  }

  /// Clears navigation history
  void _clearHistory() {
    _history.clear();
  }

  /// Gets the previous route in history
  String? get previousRoute {
    if (_history.length < 2) return null;
    return _history[_history.length - 2];
  }

  /// Gets the current route path
  String? get currentRoute {
    if (_history.isEmpty) return null;
    return _history.last;
  }
}
