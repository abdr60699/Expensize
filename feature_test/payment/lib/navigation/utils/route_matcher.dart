import '../models/app_route.dart';
import '../models/route_match.dart';

/// Utility class for matching URL paths to route configurations
class RouteMatcher {
  /// Matches a path against a list of routes
  /// Returns the best match or null if no match found
  static RouteMatch? match(
    String path,
    List<AppRoute> routes, {
    Map<String, String>? queryParameters,
  }) {
    // Remove trailing slashes and normalize
    final normalizedPath = _normalizePath(path);

    // Try exact matches first
    for (final route in routes) {
      final match = _matchRoute(
        normalizedPath,
        route,
        queryParameters ?? {},
      );
      if (match != null) {
        return match;
      }

      // Check child routes
      if (route.children.isNotEmpty) {
        final childMatch = RouteMatcher.match(
          normalizedPath,
          route.children,
          queryParameters: queryParameters,
        );
        if (childMatch != null) {
          return childMatch;
        }
      }
    }

    return null;
  }

  /// Matches a single route against a path
  static RouteMatch? _matchRoute(
    String path,
    AppRoute route,
    Map<String, String> queryParameters,
  ) {
    final routePath = _normalizePath(route.path);
    final pathSegments = _splitPath(path);
    final routeSegments = _splitPath(routePath);

    // Quick length check
    if (pathSegments.length != routeSegments.length) {
      return null;
    }

    final pathParams = <String, dynamic>{};

    // Check each segment
    for (var i = 0; i < routeSegments.length; i++) {
      final routeSegment = routeSegments[i];
      final pathSegment = pathSegments[i];

      if (routeSegment.startsWith(':')) {
        // This is a parameter
        final paramName = routeSegment.substring(1);
        pathParams[paramName] = Uri.decodeComponent(pathSegment);
      } else if (routeSegment != pathSegment) {
        // Segments don't match
        return null;
      }
    }

    return RouteMatch(
      route: route,
      pathParameters: pathParams,
      queryParameters: queryParameters,
      matchedPath: path,
      isExactMatch: true,
    );
  }

  /// Builds a path from a route and parameters
  static String buildPath(
    AppRoute route,
    Map<String, dynamic> pathParams, {
    Map<String, String>? queryParams,
  }) {
    var path = route.path;

    // Replace path parameters
    pathParams.forEach((key, value) {
      path = path.replaceAll(':$key', Uri.encodeComponent(value.toString()));
    });

    // Add query parameters
    if (queryParams != null && queryParams.isNotEmpty) {
      final query = queryParams.entries
          .map((e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
      path = '$path?$query';
    }

    return path;
  }

  /// Normalizes a path by removing trailing slashes and ensuring leading slash
  static String _normalizePath(String path) {
    if (path.isEmpty) return '/';

    // Remove query parameters for matching
    final questionMarkIndex = path.indexOf('?');
    if (questionMarkIndex != -1) {
      path = path.substring(0, questionMarkIndex);
    }

    // Ensure leading slash
    if (!path.startsWith('/')) {
      path = '/$path';
    }

    // Remove trailing slash (except for root)
    if (path.length > 1 && path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }

    return path;
  }

  /// Splits a path into segments
  static List<String> _splitPath(String path) {
    final normalized = _normalizePath(path);
    if (normalized == '/') return [];
    return normalized.substring(1).split('/');
  }

  /// Extracts query parameters from a URI string
  static Map<String, String> extractQueryParameters(String uriString) {
    try {
      final uri = Uri.parse(uriString);
      return uri.queryParameters;
    } catch (_) {
      return {};
    }
  }

  /// Checks if a path matches a route pattern
  static bool isMatch(String path, String pattern) {
    final normalizedPath = _normalizePath(path);
    final normalizedPattern = _normalizePath(pattern);

    final pathSegments = _splitPath(normalizedPath);
    final patternSegments = _splitPath(normalizedPattern);

    if (pathSegments.length != patternSegments.length) {
      return false;
    }

    for (var i = 0; i < patternSegments.length; i++) {
      final patternSegment = patternSegments[i];
      final pathSegment = pathSegments[i];

      if (!patternSegment.startsWith(':') && patternSegment != pathSegment) {
        return false;
      }
    }

    return true;
  }
}
