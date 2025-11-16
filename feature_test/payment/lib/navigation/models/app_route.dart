import 'package:flutter/material.dart';

/// Represents a route configuration in the navigation system
class AppRoute {
  /// Unique identifier for the route
  final String name;

  /// URL path pattern (e.g., '/user/:id')
  final String path;

  /// Builder function that creates the page widget
  final Widget Function(BuildContext context, Map<String, dynamic> params)
      builder;

  /// Optional parent route for nested navigation
  final AppRoute? parent;

  /// Child routes for nested navigation
  final List<AppRoute> children;

  /// Guards that must pass before navigation is allowed
  final List<String> guards;

  /// Metadata associated with this route
  final Map<String, dynamic> meta;

  /// Whether this route requires authentication
  final bool requiresAuth;

  /// Custom transition builder
  final Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  )? transitionBuilder;

  /// Transition duration
  final Duration transitionDuration;

  /// Whether to maintain state when navigating away
  final bool maintainState;

  /// Whether this is a full screen dialog
  final bool fullscreenDialog;

  const AppRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.parent,
    this.children = const [],
    this.guards = const [],
    this.meta = const {},
    this.requiresAuth = false,
    this.transitionBuilder,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.maintainState = true,
    this.fullscreenDialog = false,
  });

  /// Creates a copy of this route with modified properties
  AppRoute copyWith({
    String? name,
    String? path,
    Widget Function(BuildContext context, Map<String, dynamic> params)? builder,
    AppRoute? parent,
    List<AppRoute>? children,
    List<String>? guards,
    Map<String, dynamic>? meta,
    bool? requiresAuth,
    Widget Function(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    )? transitionBuilder,
    Duration? transitionDuration,
    bool? maintainState,
    bool? fullscreenDialog,
  }) {
    return AppRoute(
      name: name ?? this.name,
      path: path ?? this.path,
      builder: builder ?? this.builder,
      parent: parent ?? this.parent,
      children: children ?? this.children,
      guards: guards ?? this.guards,
      meta: meta ?? this.meta,
      requiresAuth: requiresAuth ?? this.requiresAuth,
      transitionBuilder: transitionBuilder ?? this.transitionBuilder,
      transitionDuration: transitionDuration ?? this.transitionDuration,
      maintainState: maintainState ?? this.maintainState,
      fullscreenDialog: fullscreenDialog ?? this.fullscreenDialog,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppRoute &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          path == other.path;

  @override
  int get hashCode => name.hashCode ^ path.hashCode;

  @override
  String toString() => 'AppRoute(name: $name, path: $path)';
}
