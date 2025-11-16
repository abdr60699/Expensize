/// # Navigation System Package
///
/// A comprehensive, production-grade navigation system for Flutter applications
/// built on top of Navigator 2.0 (Router API).
///
/// ## Features
///
/// - **Declarative Routing**: Define routes with a clean, declarative syntax
/// - **Deep Linking**: Full support for deep links and universal links
/// - **Navigation Guards**: Protect routes with authentication and authorization
/// - **Nested Navigation**: Support for complex nested navigation scenarios
/// - **Tab Navigation**: Built-in tab navigation with independent stacks
/// - **Type Safety**: Full null-safety support
/// - **Custom Transitions**: Easily add custom page transitions
/// - **URL Support**: Full URL and query parameter support
/// - **Programmatic API**: Clean imperative API alongside declarative routing
///
/// ## Usage
///
/// ```dart
/// import 'package:your_app/features/navigation/navigation.dart';
///
/// // Define routes
/// final routes = [
///   RouteConfig.route(
///     name: 'home',
///     path: '/',
///     builder: (context, params) => HomePage(),
///   ),
///   RouteConfig.route(
///     name: 'profile',
///     path: '/profile/:id',
///     builder: (context, params) => ProfilePage(id: params['id']),
///     requiresAuth: true,
///   ),
/// ];
///
/// // Setup navigation
/// final navService = NavigationService(
///   navigatorKey: GlobalKey<NavigatorState>(),
///   routes: routes,
/// );
///
/// // Use in MaterialApp
/// MaterialApp.router(
///   routerDelegate: AppRouterDelegate(routes: routes),
///   routeInformationParser: AppRouteInformationParser(),
/// );
///
/// // Navigate programmatically
/// navService.navigateTo('profile', pathParams: {'id': '123'});
/// ```
library navigation;

// Core components
export 'core/app_route_information_parser.dart';
export 'core/app_router_delegate.dart';

// Models
export 'models/app_route.dart';
export 'models/route_information.dart';
export 'models/navigation_stack.dart';
export 'models/route_match.dart';
export 'models/navigation_result.dart';

// Services
export 'services/navigation_service.dart';
export 'services/route_config.dart';

// Guards
export 'guards/navigation_guard.dart';

// Widgets
export 'widgets/nested_navigator.dart';
export 'widgets/tab_navigator.dart';

// Utilities
export 'utils/route_matcher.dart';
export 'utils/deep_link_handler.dart';

// Constants
export 'constants/navigation_constants.dart';
