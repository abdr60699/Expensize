import 'package:flutter/material.dart';
import '../models/app_route.dart';

/// Configuration class for setting up routes
/// Provides helper methods for common route configurations
class RouteConfig {
  /// Creates a simple route
  static AppRoute route({
    required String name,
    required String path,
    required Widget Function(BuildContext, Map<String, dynamic>) builder,
    bool requiresAuth = false,
    List<String> guards = const [],
    Map<String, dynamic> meta = const {},
  }) {
    return AppRoute(
      name: name,
      path: path,
      builder: builder,
      requiresAuth: requiresAuth,
      guards: guards,
      meta: meta,
    );
  }

  /// Creates a route with children (nested navigation)
  static AppRoute parent({
    required String name,
    required String path,
    required Widget Function(BuildContext, Map<String, dynamic>) builder,
    required List<AppRoute> children,
    bool requiresAuth = false,
    List<String> guards = const [],
    Map<String, dynamic> meta = const {},
  }) {
    return AppRoute(
      name: name,
      path: path,
      builder: builder,
      children: children,
      requiresAuth: requiresAuth,
      guards: guards,
      meta: meta,
    );
  }

  /// Creates a route with custom transition
  static AppRoute withTransition({
    required String name,
    required String path,
    required Widget Function(BuildContext, Map<String, dynamic>) builder,
    required RouteTransition transition,
    Duration duration = const Duration(milliseconds: 300),
    bool requiresAuth = false,
    List<String> guards = const [],
    Map<String, dynamic> meta = const {},
  }) {
    return AppRoute(
      name: name,
      path: path,
      builder: builder,
      requiresAuth: requiresAuth,
      guards: guards,
      meta: meta,
      transitionBuilder: _getTransitionBuilder(transition),
      transitionDuration: duration,
    );
  }

  /// Creates a dialog route
  static AppRoute dialog({
    required String name,
    required String path,
    required Widget Function(BuildContext, Map<String, dynamic>) builder,
    bool requiresAuth = false,
    List<String> guards = const [],
    Map<String, dynamic> meta = const {},
  }) {
    return AppRoute(
      name: name,
      path: path,
      builder: builder,
      requiresAuth: requiresAuth,
      guards: guards,
      meta: meta,
      fullscreenDialog: true,
    );
  }

  /// Gets a transition builder for a given transition type
  static Widget Function(
    BuildContext,
    Animation<double>,
    Animation<double>,
    Widget,
  ) _getTransitionBuilder(RouteTransition transition) {
    switch (transition) {
      case RouteTransition.fade:
        return _fadeTransition;
      case RouteTransition.slide:
        return _slideTransition;
      case RouteTransition.scale:
        return _scaleTransition;
      case RouteTransition.rotation:
        return _rotationTransition;
      case RouteTransition.slideFromBottom:
        return _slideFromBottomTransition;
      case RouteTransition.slideFromTop:
        return _slideFromTopTransition;
      case RouteTransition.slideFromLeft:
        return _slideFromLeftTransition;
      case RouteTransition.slideFromRight:
        return _slideFromRightTransition;
      case RouteTransition.none:
        return _noTransition;
    }
  }

  // Transition builders
  static Widget _fadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  static Widget _slideTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }

  static Widget _scaleTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(animation),
      child: child,
    );
  }

  static Widget _rotationTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return RotationTransition(
      turns: Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(animation),
      child: child,
    );
  }

  static Widget _slideFromBottomTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }

  static Widget _slideFromTopTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, -1.0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }

  static Widget _slideFromLeftTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1.0, 0.0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }

  static Widget _slideFromRightTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }

  static Widget _noTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

/// Available route transitions
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
