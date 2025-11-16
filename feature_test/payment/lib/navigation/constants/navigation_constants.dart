/// Constants used throughout the navigation system
class NavigationConstants {
  NavigationConstants._();

  /// Default transition duration
  static const defaultTransitionDuration = Duration(milliseconds: 300);

  /// Default route path
  static const defaultRoutePath = '/';

  /// Unknown route name
  static const unknownRoute = 'unknown';

  /// Not found route path
  static const notFoundPath = '/404';

  /// Error messages
  static const routeNotFoundError = 'Route not found';
  static const navigationFailedError = 'Navigation failed';
  static const guardBlockedError = 'Navigation blocked by guard';
  static const navigatorNotInitializedError = 'Navigator not initialized';

  /// Route parameter keys
  static const paramReturnUrl = 'returnUrl';
  static const paramRedirect = 'redirect';
  static const paramMessage = 'message';

  /// Common route names
  static const routeHome = '/';
  static const routeLogin = '/login';
  static const routeSignUp = '/signup';
  static const routeProfile = '/profile';
  static const routeSettings = '/settings';
  static const routeNotFound = '/404';
  static const routeUnauthorized = '/unauthorized';
}
