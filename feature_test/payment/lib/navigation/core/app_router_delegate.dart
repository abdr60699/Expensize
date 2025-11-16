import 'package:flutter/material.dart';
import '../models/app_route.dart';
import '../models/navigation_stack.dart';
import '../models/route_information.dart';
import '../models/route_match.dart';
import '../guards/navigation_guard.dart';
import '../utils/route_matcher.dart';
import '../services/navigation_service.dart';

/// The router delegate manages the app's navigation state
/// This is the core of the Navigator 2.0 implementation
class AppRouterDelegate extends RouterDelegate<AppRouteInformation>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRouteInformation> {
  /// Global navigator key
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  /// All available routes
  final List<AppRoute> routes;

  /// Registered navigation guards
  final Map<String, NavigationGuard> guards;

  /// The current navigation stack
  NavigationStack _stack;

  /// The navigation service instance
  final NavigationService? navigationService;

  /// Route to show when no match is found (404)
  final AppRoute? notFoundRoute;

  /// Default route (usually '/' or home)
  final String defaultRoute;

  /// Observers for navigation events
  final List<NavigatorObserver> observers;

  /// Whether to enable transition animations
  final bool enableTransitions;

  AppRouterDelegate({
    required this.routes,
    this.guards = const {},
    this.navigationService,
    this.notFoundRoute,
    this.defaultRoute = '/',
    this.observers = const [],
    this.enableTransitions = true,
    GlobalKey<NavigatorState>? navigatorKey,
  })  : navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>(),
        _stack = const NavigationStack() {
    // Initialize with default route
    _initializeDefaultRoute();
  }

  /// Gets the current navigation stack
  NavigationStack get stack => _stack;

  /// Gets the current route information
  @override
  AppRouteInformation? get currentConfiguration {
    if (_stack.isEmpty) {
      return AppRouteInformation(location: defaultRoute);
    }

    final current = _stack.current!;
    final path = RouteMatcher.buildPath(
      current.route,
      current.pathParameters,
      queryParams: current.queryParameters,
    );

    return AppRouteInformation(
      location: path,
      pathParameters: current.pathParameters,
      queryParameters: current.queryParameters,
      state: current.arguments,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      observers: observers,
      pages: _buildPages(),
      onPopPage: _onPopPage,
    );
  }

  /// Builds the list of pages from the navigation stack
  List<Page> _buildPages() {
    if (_stack.isEmpty) {
      // Show default route
      final match = RouteMatcher.match(defaultRoute, routes);
      if (match != null) {
        return [_createPage(match, UniqueKey().toString())];
      }

      // Show 404 if default route not found
      if (notFoundRoute != null) {
        return [
          _createPage(
            RouteMatch(
              route: notFoundRoute!,
              matchedPath: defaultRoute,
            ),
            UniqueKey().toString(),
          ),
        ];
      }

      return [];
    }

    return _stack.pages.map((navPage) {
      return _createPage(
        RouteMatch(
          route: navPage.route,
          pathParameters: navPage.pathParameters,
          queryParameters: navPage.queryParameters,
          matchedPath: RouteMatcher.buildPath(
            navPage.route,
            navPage.pathParameters,
          ),
        ),
        navPage.key,
        arguments: navPage.arguments,
      );
    }).toList();
  }

  /// Creates a page from a route match
  Page _createPage(
    RouteMatch match,
    String key, {
    Object? arguments,
  }) {
    final route = match.route;

    if (route.transitionBuilder != null && enableTransitions) {
      return CustomTransitionPage(
        key: ValueKey(key),
        child: route.builder(
          navigatorKey.currentContext!,
          {
            ...match.pathParameters,
            ...match.queryParameters,
          },
        ),
        transitionsBuilder: route.transitionBuilder!,
        transitionDuration: route.transitionDuration,
        maintainState: route.maintainState,
        fullscreenDialog: route.fullscreenDialog,
      );
    }

    return MaterialPage(
      key: ValueKey(key),
      child: route.builder(
        navigatorKey.currentContext!,
        {
          ...match.pathParameters,
          ...match.queryParameters,
        },
      ),
      maintainState: route.maintainState,
      fullscreenDialog: route.fullscreenDialog,
    );
  }

  /// Handles pop requests
  bool _onPopPage(Route<dynamic> route, dynamic result) {
    if (!route.didPop(result)) {
      return false;
    }

    if (_stack.isNotEmpty) {
      _stack = _stack.pop();
      notifyListeners();
    }

    return true;
  }

  @override
  Future<void> setNewRoutePath(AppRouteInformation configuration) async {
    final match = RouteMatcher.match(
      configuration.location,
      routes,
      queryParameters: configuration.queryParameters,
    );

    if (match == null) {
      // Route not found
      if (notFoundRoute != null) {
        _pushPage(
          RouteMatch(
            route: notFoundRoute!,
            matchedPath: configuration.location,
            queryParameters: configuration.queryParameters,
          ),
        );
      }
      return;
    }

    // Check guards
    final guardResult = await _checkGuards(match);
    if (!guardResult.canNavigate) {
      if (guardResult.redirectTo != null) {
        // Redirect to another route
        await setNewRoutePath(
          AppRouteInformation(location: guardResult.redirectTo!),
        );
      }
      return;
    }

    _pushPage(match);
  }

  /// Pushes a new page onto the stack
  void _pushPage(RouteMatch match, {Object? arguments}) {
    final page = NavigationPage(
      route: match.route,
      pathParameters: match.pathParameters,
      queryParameters: match.queryParameters,
      key: '${match.route.name}_${DateTime.now().millisecondsSinceEpoch}',
      arguments: arguments,
    );

    _stack = _stack.push(page);
    notifyListeners();
  }

  /// Checks all guards for a route
  Future<GuardResult> _checkGuards(RouteMatch match) async {
    // Check global guards first
    for (final guardName in match.route.guards) {
      final guard = guards[guardName];
      if (guard != null) {
        final result = await guard.canNavigate(match, {});
        if (!result.canNavigate) {
          return result;
        }
      }
    }

    return GuardResult.allow();
  }

  /// Initializes the default route
  void _initializeDefaultRoute() {
    final match = RouteMatcher.match(defaultRoute, routes);
    if (match != null) {
      _pushPage(match);
    }
  }

  /// Clears the navigation stack
  void clear() {
    _stack = const NavigationStack();
    notifyListeners();
  }

  /// Replaces the entire stack with a new route
  void replaceAll(String routeName, {Map<String, dynamic>? params}) {
    final match = RouteMatcher.match(routeName, routes);
    if (match != null) {
      final page = NavigationPage(
        route: match.route,
        pathParameters: params ?? {},
        key: '${match.route.name}_${DateTime.now().millisecondsSinceEpoch}',
      );
      _stack = NavigationStack.single(page);
      notifyListeners();
    }
  }
}

/// Custom page with transition support
class CustomTransitionPage<T> extends Page<T> {
  final Widget child;
  final Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) transitionsBuilder;
  final Duration transitionDuration;
  final bool maintainState;
  final bool fullscreenDialog;

  const CustomTransitionPage({
    required this.child,
    required this.transitionsBuilder,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.maintainState = true,
    this.fullscreenDialog = false,
    super.key,
  });

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder<T>(
      settings: this,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: transitionsBuilder,
      transitionDuration: transitionDuration,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
    );
  }
}
