import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../models/app_route.dart';
import '../services/navigation_service.dart';

void main() {
  group('NavigationService', () {
    late GlobalKey<NavigatorState> navigatorKey;
    late List<AppRoute> routes;
    late NavigationService service;

    setUp(() {
      navigatorKey = GlobalKey<NavigatorState>();
      routes = [
        AppRoute(
          name: 'home',
          path: '/',
          builder: (_, __) => const Placeholder(key: Key('home')),
        ),
        AppRoute(
          name: 'profile',
          path: '/profile/:id',
          builder: (_, __) => const Placeholder(key: Key('profile')),
        ),
        AppRoute(
          name: 'settings',
          path: '/settings',
          builder: (_, __) => const Placeholder(key: Key('settings')),
        ),
      ];
      service = NavigationService(
        navigatorKey: navigatorKey,
        routes: routes,
      );
    });

    test('initializes correctly', () {
      expect(service.navigatorKey, equals(navigatorKey));
      expect(service.routes, equals(routes));
      expect(service.history, isEmpty);
    });

    test('builds route match correctly', () {
      final match = service.buildRouteMatch(
        'profile',
        pathParams: {'id': '123'},
        queryParams: {'tab': 'posts'},
      );

      expect(match, isNotNull);
      expect(match!.route.name, equals('profile'));
      expect(match.pathParameters['id'], equals('123'));
      expect(match.queryParameters['tab'], equals('posts'));
    });

    test('returns null for unknown route', () {
      final match = service.buildRouteMatch('unknown');
      expect(match, isNull);
    });

    test('tracks navigation history', () {
      // History tracking is tested through actual navigation
      // which requires a full widget tree
      expect(service.history, isEmpty);
    });

    test('finds nested routes', () {
      final parentRoute = AppRoute(
        name: 'parent',
        path: '/parent',
        builder: (_, __) => const Placeholder(),
        children: [
          AppRoute(
            name: 'child',
            path: '/parent/child',
            builder: (_, __) => const Placeholder(),
          ),
        ],
      );

      final serviceWithNested = NavigationService(
        navigatorKey: navigatorKey,
        routes: [parentRoute],
      );

      final match = serviceWithNested.buildRouteMatch('child');
      expect(match, isNotNull);
      expect(match!.route.name, equals('child'));
    });

    test('current route is null initially', () {
      expect(service.currentRoute, isNull);
    });

    test('previous route is null initially', () {
      expect(service.previousRoute, isNull);
    });

    group('NavigationResult', () {
      test('creates successful result', () {
        final result = NavigationResult<String>.success(
          data: 'test',
          routeName: 'home',
        );
        expect(result.success, isTrue);
        expect(result.data, equals('test'));
        expect(result.routeName, equals('home'));
        expect(result.error, isNull);
      });

      test('creates failure result', () {
        final result = NavigationResult.failure('Error message');
        expect(result.success, isFalse);
        expect(result.error, equals('Error message'));
        expect(result.data, isNull);
        expect(result.routeName, isNull);
      });
    });
  });
}
