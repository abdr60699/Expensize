import 'package:flutter/foundation.dart';

/// Represents the current navigation state
@immutable
class AppRouteInformation {
  /// The current location (URL path)
  final String location;

  /// Query parameters
  final Map<String, String> queryParameters;

  /// Path parameters (extracted from route pattern)
  final Map<String, dynamic> pathParameters;

  /// Additional state data
  final Object? state;

  const AppRouteInformation({
    required this.location,
    this.queryParameters = const {},
    this.pathParameters = const {},
    this.state,
  });

  /// Creates a copy with modified properties
  AppRouteInformation copyWith({
    String? location,
    Map<String, String>? queryParameters,
    Map<String, dynamic>? pathParameters,
    Object? state,
  }) {
    return AppRouteInformation(
      location: location ?? this.location,
      queryParameters: queryParameters ?? this.queryParameters,
      pathParameters: pathParameters ?? this.pathParameters,
      state: state ?? this.state,
    );
  }

  /// Parses a URI string into AppRouteInformation
  factory AppRouteInformation.fromUri(Uri uri) {
    return AppRouteInformation(
      location: uri.path,
      queryParameters: uri.queryParameters,
    );
  }

  /// Converts to a Uri
  Uri toUri() {
    return Uri(
      path: location,
      queryParameters:
          queryParameters.isEmpty ? null : queryParameters,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppRouteInformation &&
          runtimeType == other.runtimeType &&
          location == other.location &&
          mapEquals(queryParameters, other.queryParameters) &&
          mapEquals(pathParameters, other.pathParameters);

  @override
  int get hashCode =>
      location.hashCode ^
      queryParameters.hashCode ^
      pathParameters.hashCode;

  @override
  String toString() {
    return 'AppRouteInformation(location: $location, '
        'queryParams: $queryParameters, pathParams: $pathParameters)';
  }
}
