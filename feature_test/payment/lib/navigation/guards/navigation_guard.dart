import '../models/route_match.dart';

/// Result of a navigation guard check
class GuardResult {
  /// Whether navigation is allowed
  final bool canNavigate;

  /// Optional redirect route name if navigation should be redirected
  final String? redirectTo;

  /// Optional error message
  final String? message;

  /// Additional data to pass to redirect route
  final Map<String, dynamic>? redirectData;

  const GuardResult({
    required this.canNavigate,
    this.redirectTo,
    this.message,
    this.redirectData,
  });

  /// Creates a result that allows navigation
  factory GuardResult.allow() {
    return const GuardResult(canNavigate: true);
  }

  /// Creates a result that denies navigation
  factory GuardResult.deny([String? message]) {
    return GuardResult(
      canNavigate: false,
      message: message,
    );
  }

  /// Creates a result that redirects to another route
  factory GuardResult.redirect(
    String routeName, {
    Map<String, dynamic>? data,
    String? message,
  }) {
    return GuardResult(
      canNavigate: false,
      redirectTo: routeName,
      redirectData: data,
      message: message,
    );
  }

  @override
  String toString() {
    if (canNavigate) return 'GuardResult.allow()';
    if (redirectTo != null) {
      return 'GuardResult.redirect($redirectTo)';
    }
    return 'GuardResult.deny($message)';
  }
}

/// Abstract base class for navigation guards
abstract class NavigationGuard {
  /// Unique identifier for this guard
  String get name;

  /// Checks if navigation to the given route is allowed
  /// Returns a [GuardResult] indicating whether to allow, deny, or redirect
  Future<GuardResult> canNavigate(
    RouteMatch match,
    Map<String, dynamic> context,
  );

  /// Optional: Called after successful navigation
  Future<void> onNavigationComplete(RouteMatch match) async {}

  /// Optional: Called when navigation is cancelled
  Future<void> onNavigationCancelled(RouteMatch match) async {}
}

/// A simple guard that always allows navigation
class AllowAllGuard extends NavigationGuard {
  @override
  String get name => 'allow_all';

  @override
  Future<GuardResult> canNavigate(
    RouteMatch match,
    Map<String, dynamic> context,
  ) async {
    return GuardResult.allow();
  }
}

/// Example: Authentication guard
class AuthGuard extends NavigationGuard {
  final Future<bool> Function() isAuthenticated;
  final String loginRoute;

  AuthGuard({
    required this.isAuthenticated,
    this.loginRoute = '/login',
  });

  @override
  String get name => 'auth_guard';

  @override
  Future<GuardResult> canNavigate(
    RouteMatch match,
    Map<String, dynamic> context,
  ) async {
    final authenticated = await isAuthenticated();

    if (!authenticated && match.route.requiresAuth) {
      return GuardResult.redirect(
        loginRoute,
        message: 'Authentication required',
        data: {'returnUrl': match.matchedPath},
      );
    }

    return GuardResult.allow();
  }
}

/// Example: Role-based guard
class RoleGuard extends NavigationGuard {
  final Future<List<String>> Function() getUserRoles;
  final List<String> requiredRoles;
  final String unauthorizedRoute;

  RoleGuard({
    required this.getUserRoles,
    required this.requiredRoles,
    this.unauthorizedRoute = '/unauthorized',
  });

  @override
  String get name => 'role_guard';

  @override
  Future<GuardResult> canNavigate(
    RouteMatch match,
    Map<String, dynamic> context,
  ) async {
    final userRoles = await getUserRoles();
    final hasRequiredRole = requiredRoles.any(
      (role) => userRoles.contains(role),
    );

    if (!hasRequiredRole) {
      return GuardResult.redirect(
        unauthorizedRoute,
        message: 'Insufficient permissions',
      );
    }

    return GuardResult.allow();
  }
}
