import 'app_route.dart';

/// Represents a matched route with extracted parameters
class RouteMatch {
  /// The matched route
  final AppRoute route;

  /// Path parameters extracted from the URL
  final Map<String, dynamic> pathParameters;

  /// Query parameters from the URL
  final Map<String, String> queryParameters;

  /// The original path that was matched
  final String matchedPath;

  /// Whether this is an exact match
  final bool isExactMatch;

  const RouteMatch({
    required this.route,
    required this.matchedPath,
    this.pathParameters = const {},
    this.queryParameters = const {},
    this.isExactMatch = true,
  });

  /// Creates a copy with modified properties
  RouteMatch copyWith({
    AppRoute? route,
    Map<String, dynamic>? pathParameters,
    Map<String, String>? queryParameters,
    String? matchedPath,
    bool? isExactMatch,
  }) {
    return RouteMatch(
      route: route ?? this.route,
      pathParameters: pathParameters ?? this.pathParameters,
      queryParameters: queryParameters ?? this.queryParameters,
      matchedPath: matchedPath ?? this.matchedPath,
      isExactMatch: isExactMatch ?? this.isExactMatch,
    );
  }

  @override
  String toString() {
    return 'RouteMatch(route: ${route.name}, '
        'path: $matchedPath, params: $pathParameters)';
  }
}
