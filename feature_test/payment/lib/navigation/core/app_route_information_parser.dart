import 'package:flutter/material.dart';
import '../models/route_information.dart';

/// Parses route information from the operating system
/// This is part of the Navigator 2.0 API
class AppRouteInformationParser
    extends RouteInformationParser<AppRouteInformation> {
  const AppRouteInformationParser();

  @override
  Future<AppRouteInformation> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final uri = routeInformation.uri;

    return AppRouteInformation(
      location: uri.path,
      queryParameters: uri.queryParameters,
      state: routeInformation.state,
    );
  }

  @override
  RouteInformation? restoreRouteInformation(
    AppRouteInformation configuration,
  ) {
    return RouteInformation(
      uri: configuration.toUri(),
      state: configuration.state,
    );
  }
}
