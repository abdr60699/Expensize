import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../guards/navigation_guard.dart';
import '../models/app_route.dart';
import '../models/route_match.dart';

void main() {
  group('NavigationGuard', () {
    group('GuardResult', () {
      test('allow creates allowing result', () {
        final result = GuardResult.allow();
        expect(result.canNavigate, isTrue);
        expect(result.redirectTo, isNull);
        expect(result.message, isNull);
      });

      test('deny creates denying result', () {
        final result = GuardResult.deny('Not allowed');
        expect(result.canNavigate, isFalse);
        expect(result.message, equals('Not allowed'));
      });

      test('redirect creates redirecting result', () {
        final result = GuardResult.redirect(
          '/login',
          data: {'returnUrl': '/profile'},
          message: 'Please login',
        );
        expect(result.canNavigate, isFalse);
        expect(result.redirectTo, equals('/login'));
        expect(result.message, equals('Please login'));
        expect(result.redirectData!['returnUrl'], equals('/profile'));
      });
    });

    group('AllowAllGuard', () {
      test('always allows navigation', () async {
        final guard = AllowAllGuard();
        final route = AppRoute(
          name: 'test',
          path: '/test',
          builder: (_, __) => const Placeholder(),
        );
        final match = RouteMatch(
          route: route,
          matchedPath: '/test',
        );

        final result = await guard.canNavigate(match, {});
        expect(result.canNavigate, isTrue);
      });
    });

    group('AuthGuard', () {
      test('allows navigation when authenticated', () async {
        final guard = AuthGuard(
          isAuthenticated: () async => true,
        );

        final route = AppRoute(
          name: 'profile',
          path: '/profile',
          builder: (_, __) => const Placeholder(),
          requiresAuth: true,
        );

        final match = RouteMatch(
          route: route,
          matchedPath: '/profile',
        );

        final result = await guard.canNavigate(match, {});
        expect(result.canNavigate, isTrue);
      });

      test('redirects when not authenticated', () async {
        final guard = AuthGuard(
          isAuthenticated: () async => false,
          loginRoute: '/login',
        );

        final route = AppRoute(
          name: 'profile',
          path: '/profile',
          builder: (_, __) => const Placeholder(),
          requiresAuth: true,
        );

        final match = RouteMatch(
          route: route,
          matchedPath: '/profile',
        );

        final result = await guard.canNavigate(match, {});
        expect(result.canNavigate, isFalse);
        expect(result.redirectTo, equals('/login'));
        expect(result.redirectData!['returnUrl'], equals('/profile'));
      });

      test('allows navigation to public routes', () async {
        final guard = AuthGuard(
          isAuthenticated: () async => false,
        );

        final route = AppRoute(
          name: 'home',
          path: '/',
          builder: (_, __) => const Placeholder(),
          requiresAuth: false,
        );

        final match = RouteMatch(
          route: route,
          matchedPath: '/',
        );

        final result = await guard.canNavigate(match, {});
        expect(result.canNavigate, isTrue);
      });
    });

    group('RoleGuard', () {
      test('allows navigation with correct role', () async {
        final guard = RoleGuard(
          getUserRoles: () async => ['admin', 'user'],
          requiredRoles: ['admin'],
        );

        final route = AppRoute(
          name: 'admin',
          path: '/admin',
          builder: (_, __) => const Placeholder(),
        );

        final match = RouteMatch(
          route: route,
          matchedPath: '/admin',
        );

        final result = await guard.canNavigate(match, {});
        expect(result.canNavigate, isTrue);
      });

      test('redirects without required role', () async {
        final guard = RoleGuard(
          getUserRoles: () async => ['user'],
          requiredRoles: ['admin'],
          unauthorizedRoute: '/unauthorized',
        );

        final route = AppRoute(
          name: 'admin',
          path: '/admin',
          builder: (_, __) => const Placeholder(),
        );

        final match = RouteMatch(
          route: route,
          matchedPath: '/admin',
        );

        final result = await guard.canNavigate(match, {});
        expect(result.canNavigate, isFalse);
        expect(result.redirectTo, equals('/unauthorized'));
      });
    });
  });
}
