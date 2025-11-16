# Navigation System - API Reference

Complete API documentation for the Navigation System.

## Table of Contents

- [Core Classes](#core-classes)
- [Models](#models)
- [Services](#services)
- [Guards](#guards)
- [Widgets](#widgets)
- [Utilities](#utilities)

---

## Core Classes

### AppRouterDelegate

The main router delegate managing navigation state.

```dart
class AppRouterDelegate extends RouterDelegate<AppRouteInformation>
```

**Constructor:**
```dart
AppRouterDelegate({
  required List<AppRoute> routes,
  Map<String, NavigationGuard> guards = const {},
  NavigationService? navigationService,
  AppRoute? notFoundRoute,
  String defaultRoute = '/',
  List<NavigatorObserver> observers = const [],
  bool enableTransitions = true,
  GlobalKey<NavigatorState>? navigatorKey,
})
```

**Properties:**
- `routes` - List of available routes
- `guards` - Map of registered navigation guards
- `notFoundRoute` - Route to show for 404
- `defaultRoute` - Initial route (default: '/')
- `observers` - Navigation observers
- `enableTransitions` - Enable/disable transitions

**Methods:**
- `build(BuildContext context)` - Builds the navigator
- `setNewRoutePath(AppRouteInformation configuration)` - Handles route changes
- `clear()` - Clears navigation stack
- `replaceAll(String routeName, {Map<String, dynamic>? params})` - Replaces entire stack

---

### AppRouteInformationParser

Parses route information from URLs.

```dart
class AppRouteInformationParser
    extends RouteInformationParser<AppRouteInformation>
```

**Methods:**
- `parseRouteInformation(RouteInformation routeInformation)` - Parses incoming route
- `restoreRouteInformation(AppRouteInformation configuration)` - Restores route info

---

## Models

### AppRoute

Represents a route configuration.

```dart
class AppRoute {
  final String name;
  final String path;
  final Widget Function(BuildContext, Map<String, dynamic>) builder;
  final AppRoute? parent;
  final List<AppRoute> children;
  final List<String> guards;
  final Map<String, dynamic> meta;
  final bool requiresAuth;
  final Widget Function(...)? transitionBuilder;
  final Duration transitionDuration;
  final bool maintainState;
  final bool fullscreenDialog;
}
```

**Constructor:**
```dart
const AppRoute({
  required String name,
  required String path,
  required Widget Function(BuildContext, Map<String, dynamic>) builder,
  AppRoute? parent,
  List<AppRoute> children = const [],
  List<String> guards = const [],
  Map<String, dynamic> meta = const {},
  bool requiresAuth = false,
  Widget Function(...)? transitionBuilder,
  Duration transitionDuration = const Duration(milliseconds: 300),
  bool maintainState = true,
  bool fullscreenDialog = false,
})
```

**Methods:**
- `copyWith({...})` - Creates a copy with modified properties

---

### AppRouteInformation

Represents current navigation state.

```dart
class AppRouteInformation {
  final String location;
  final Map<String, String> queryParameters;
  final Map<String, dynamic> pathParameters;
  final Object? state;
}
```

**Factory Constructors:**
- `AppRouteInformation.fromUri(Uri uri)` - Creates from URI

**Methods:**
- `copyWith({...})` - Creates a copy with modified properties
- `toUri()` - Converts to Uri

---

### NavigationStack

Represents the navigation stack.

```dart
class NavigationStack {
  final List<NavigationPage> pages;
  NavigationPage? get current;
  bool get isEmpty;
  bool get isNotEmpty;
  int get length;
}
```

**Factory Constructors:**
- `NavigationStack.single(NavigationPage page)` - Creates stack with single page

**Methods:**
- `push(NavigationPage page)` - Pushes new page
- `pop()` - Pops top page
- `replace(List<NavigationPage> newPages)` - Replaces all pages
- `popUntil(bool Function(NavigationPage) predicate)` - Pops until condition
- `pushAndRemoveUntil(NavigationPage page, ...)` - Pushes and removes until condition
- `replaceCurrent(NavigationPage page)` - Replaces current page
- `getPage(int index)` - Gets page by index
- `findByRouteName(String name)` - Finds page by route name

---

### RouteMatch

Represents a matched route with parameters.

```dart
class RouteMatch {
  final AppRoute route;
  final Map<String, dynamic> pathParameters;
  final Map<String, String> queryParameters;
  final String matchedPath;
  final bool isExactMatch;
}
```

---

### NavigationResult<T>

Result of a navigation operation.

```dart
class NavigationResult<T> {
  final bool success;
  final String? error;
  final T? data;
  final String? routeName;
}
```

**Factory Constructors:**
- `NavigationResult.success({T? data, String? routeName})`
- `NavigationResult.failure(String error)`

---

## Services

### NavigationService

Main service for programmatic navigation.

```dart
class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey;
  final List<AppRoute> routes;
  List<String> get history;
  BuildContext? get context;
  NavigatorState? get navigator;
  String? get currentRoute;
  String? get previousRoute;
}
```

**Constructor:**
```dart
NavigationService({
  required GlobalKey<NavigatorState> navigatorKey,
  required List<AppRoute> routes,
})
```

**Methods:**

#### Navigation
```dart
Future<NavigationResult<T>> navigateTo<T>(
  String routeName, {
  Map<String, dynamic>? pathParams,
  Map<String, String>? queryParams,
  Object? arguments,
})

Future<NavigationResult<T>> navigateAndRemoveUntil<T>(
  String routeName, {
  Map<String, dynamic>? pathParams,
  Map<String, String>? queryParams,
  bool Function(Route<dynamic>)? predicate,
})

Future<NavigationResult<T>> replace<T>(
  String routeName, {
  Map<String, dynamic>? pathParams,
  Map<String, String>? queryParams,
  Object? arguments,
})

void pop<T>([T? result])

void popUntil(String routeName)

bool canPop()

void popToRoot()
```

#### Dialogs & Sheets
```dart
Future<T?> showDialog<T>({
  required Widget Function(BuildContext) builder,
  bool barrierDismissible = true,
  Color? barrierColor,
  String? barrierLabel,
})

Future<T?> showBottomSheet<T>({
  required Widget Function(BuildContext) builder,
  bool isDismissible = true,
  bool enableDrag = true,
  Color? backgroundColor,
})

void showSnackBar({
  required String message,
  Duration duration = const Duration(seconds: 3),
  SnackBarAction? action,
})
```

#### Utilities
```dart
Future<T?> navigateWithCustomRoute<T>(Route<T> route)

RouteMatch? buildRouteMatch(
  String routeName, {
  Map<String, dynamic>? pathParams,
  Map<String, String>? queryParams,
})
```

---

### RouteConfig

Helper class for creating route configurations.

```dart
class RouteConfig
```

**Static Methods:**

```dart
static AppRoute route({
  required String name,
  required String path,
  required Widget Function(BuildContext, Map<String, dynamic>) builder,
  bool requiresAuth = false,
  List<String> guards = const [],
  Map<String, dynamic> meta = const {},
})

static AppRoute parent({
  required String name,
  required String path,
  required Widget Function(BuildContext, Map<String, dynamic>) builder,
  required List<AppRoute> children,
  bool requiresAuth = false,
  List<String> guards = const [],
  Map<String, dynamic> meta = const {},
})

static AppRoute withTransition({
  required String name,
  required String path,
  required Widget Function(BuildContext, Map<String, dynamic>) builder,
  required RouteTransition transition,
  Duration duration = const Duration(milliseconds: 300),
  bool requiresAuth = false,
  List<String> guards = const [],
  Map<String, dynamic> meta = const {},
})

static AppRoute dialog({
  required String name,
  required String path,
  required Widget Function(BuildContext, Map<String, dynamic>) builder,
  bool requiresAuth = false,
  List<String> guards = const [],
  Map<String, dynamic> meta = const {},
})
```

**Enums:**
```dart
enum RouteTransition {
  fade,
  slide,
  scale,
  rotation,
  slideFromBottom,
  slideFromTop,
  slideFromLeft,
  slideFromRight,
  none,
}
```

---

## Guards

### NavigationGuard

Abstract base class for navigation guards.

```dart
abstract class NavigationGuard {
  String get name;

  Future<GuardResult> canNavigate(
    RouteMatch match,
    Map<String, dynamic> context,
  );

  Future<void> onNavigationComplete(RouteMatch match) async {}

  Future<void> onNavigationCancelled(RouteMatch match) async {}
}
```

---

### GuardResult

Result of a guard check.

```dart
class GuardResult {
  final bool canNavigate;
  final String? redirectTo;
  final String? message;
  final Map<String, dynamic>? redirectData;
}
```

**Factory Constructors:**
```dart
factory GuardResult.allow()

factory GuardResult.deny([String? message])

factory GuardResult.redirect(
  String routeName, {
  Map<String, dynamic>? data,
  String? message,
})
```

---

### AuthGuard

Built-in authentication guard.

```dart
class AuthGuard extends NavigationGuard {
  final Future<bool> Function() isAuthenticated;
  final String loginRoute;
}
```

**Constructor:**
```dart
AuthGuard({
  required Future<bool> Function() isAuthenticated,
  String loginRoute = '/login',
})
```

---

### RoleGuard

Built-in role-based guard.

```dart
class RoleGuard extends NavigationGuard {
  final Future<List<String>> Function() getUserRoles;
  final List<String> requiredRoles;
  final String unauthorizedRoute;
}
```

**Constructor:**
```dart
RoleGuard({
  required Future<List<String>> Function() getUserRoles,
  required List<String> requiredRoles,
  String unauthorizedRoute = '/unauthorized',
})
```

---

## Widgets

### NestedNavigator

Widget for nested navigation.

```dart
class NestedNavigator extends StatefulWidget {
  final List<AppRoute> routes;
  final String initialRoute;
  final GlobalKey<NavigatorState>? navigatorKey;
  final List<NavigatorObserver> observers;
  final bool enableTransitions;
}
```

**Constructor:**
```dart
const NestedNavigator({
  Key? key,
  required List<AppRoute> routes,
  required String initialRoute,
  GlobalKey<NavigatorState>? navigatorKey,
  List<NavigatorObserver> observers = const [],
  bool enableTransitions = true,
})
```

---

### TabNavigator

Widget for tab-based navigation.

```dart
class TabNavigator extends StatefulWidget {
  final List<TabItem> tabs;
  final int initialIndex;
  final void Function(int index)? onTabChanged;
  final bool preserveState;
  final BottomNavigationBarType type;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double iconSize;
  final double selectedFontSize;
  final double unselectedFontSize;
}
```

---

### TabItem

Configuration for a tab.

```dart
class TabItem {
  final String id;
  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final List<AppRoute> routes;
  final String initialRoute;
  final GlobalKey<NavigatorState>? navigatorKey;
}
```

---

## Utilities

### RouteMatcher

Utility for matching routes.

```dart
class RouteMatcher
```

**Static Methods:**

```dart
static RouteMatch? match(
  String path,
  List<AppRoute> routes, {
  Map<String, String>? queryParameters,
})

static String buildPath(
  AppRoute route,
  Map<String, dynamic> pathParams, {
  Map<String, String>? queryParams,
})

static bool isMatch(String path, String pattern)

static Map<String, String> extractQueryParameters(String uriString)
```

---

### DeepLinkHandler

Handles deep links and universal links.

```dart
class DeepLinkHandler {
  final NavigationService navigationService;
  final List<AppRoute> routes;
  Stream<Uri> get deepLinkStream;
}
```

**Constructor:**
```dart
DeepLinkHandler({
  required NavigationService navigationService,
  required List<AppRoute> routes,
})
```

**Methods:**

```dart
Future<void> initialize()

Future<void> handleDeepLink(Uri uri)

String createDeepLink({
  required String scheme,
  required String host,
  required String routePath,
  Map<String, String>? queryParams,
})

DeepLinkData? parseDeepLink(String url)

void dispose()
```

---

### DeepLinkData

Data extracted from a deep link.

```dart
class DeepLinkData {
  final String scheme;
  final String host;
  final String path;
  final Map<String, String> queryParameters;
}
```

---

## Constants

### NavigationConstants

Common constants.

```dart
class NavigationConstants {
  static const defaultTransitionDuration = Duration(milliseconds: 300);
  static const defaultRoutePath = '/';
  static const unknownRoute = 'unknown';
  static const notFoundPath = '/404';

  // Error messages
  static const routeNotFoundError = 'Route not found';
  static const navigationFailedError = 'Navigation failed';
  static const guardBlockedError = 'Navigation blocked by guard';
  static const navigatorNotInitializedError = 'Navigator not initialized';

  // Route parameter keys
  static const paramReturnUrl = 'returnUrl';
  static const paramRedirect = 'redirect';
  static const paramMessage = 'message';

  // Common route names
  static const routeHome = '/';
  static const routeLogin = '/login';
  static const routeSignUp = '/signup';
  static const routeProfile = '/profile';
  static const routeSettings = '/settings';
  static const routeNotFound = '/404';
  static const routeUnauthorized = '/unauthorized';
}
```

---

## Example Usage

### Complete Setup

```dart
import 'package:reuablewidgets/features/navigation/navigation.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppRouterDelegate _routerDelegate;
  late final AppRouteInformationParser _parser;
  late final NavigationService _navService;

  @override
  void initState() {
    super.initState();

    final key = GlobalKey<NavigatorState>();
    final routes = [
      RouteConfig.route(
        name: 'home',
        path: '/',
        builder: (_, __) => HomePage(),
      ),
    ];

    _navService = NavigationService(
      navigatorKey: key,
      routes: routes,
    );

    _routerDelegate = AppRouterDelegate(
      routes: routes,
      navigatorKey: key,
      navigationService: _navService,
    );

    _parser = const AppRouteInformationParser();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: _routerDelegate,
      routeInformationParser: _parser,
    );
  }
}
```

---

**For more examples, see the [examples](./examples/) directory.**
