import 'package:flutter/material.dart';
import '../models/app_route.dart';
import '../core/app_router_delegate.dart';
import '../core/app_route_information_parser.dart';

/// A widget that provides nested navigation
/// Useful for tab bars, drawers, or any nested navigation scenario
class NestedNavigator extends StatefulWidget {
  /// The routes available in this nested navigator
  final List<AppRoute> routes;

  /// The initial route to display
  final String initialRoute;

  /// Navigator key for this nested navigator
  final GlobalKey<NavigatorState>? navigatorKey;

  /// Observers for navigation events
  final List<NavigatorObserver> observers;

  /// Whether to enable transitions
  final bool enableTransitions;

  const NestedNavigator({
    super.key,
    required this.routes,
    required this.initialRoute,
    this.navigatorKey,
    this.observers = const [],
    this.enableTransitions = true,
  });

  @override
  State<NestedNavigator> createState() => _NestedNavigatorState();
}

class _NestedNavigatorState extends State<NestedNavigator> {
  late AppRouterDelegate _routerDelegate;
  late AppRouteInformationParser _routeInformationParser;

  @override
  void initState() {
    super.initState();
    _routerDelegate = AppRouterDelegate(
      routes: widget.routes,
      defaultRoute: widget.initialRoute,
      navigatorKey: widget.navigatorKey,
      observers: widget.observers,
      enableTransitions: widget.enableTransitions,
    );
    _routeInformationParser = const AppRouteInformationParser();
  }

  @override
  void dispose() {
    _routerDelegate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Router(
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeInformationParser,
    );
  }
}
