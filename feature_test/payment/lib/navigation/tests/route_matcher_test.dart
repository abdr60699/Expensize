import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../models/app_route.dart';
import '../utils/route_matcher.dart';

void main() {
  group('RouteMatcher', () {
    final testRoutes = [
      AppRoute(
        name: 'home',
        path: '/',
        builder: (_, __) => const Placeholder(),
      ),
      AppRoute(
        name: 'profile',
        path: '/profile/:id',
        builder: (_, __) => const Placeholder(),
      ),
      AppRoute(
        name: 'settings',
        path: '/settings',
        builder: (_, __) => const Placeholder(),
      ),
      AppRoute(
        name: 'user-posts',
        path: '/user/:userId/posts/:postId',
        builder: (_, __) => const Placeholder(),
      ),
    ];

    group('match', () {
      test('matches simple route', () {
        final match = RouteMatcher.match('/', testRoutes);
        expect(match, isNotNull);
        expect(match!.route.name, equals('home'));
        expect(match.isExactMatch, isTrue);
      });

      test('matches route with single parameter', () {
        final match = RouteMatcher.match('/profile/123', testRoutes);
        expect(match, isNotNull);
        expect(match!.route.name, equals('profile'));
        expect(match.pathParameters['id'], equals('123'));
      });

      test('matches route with multiple parameters', () {
        final match = RouteMatcher.match(
          '/user/456/posts/789',
          testRoutes,
        );
        expect(match, isNotNull);
        expect(match!.route.name, equals('user-posts'));
        expect(match.pathParameters['userId'], equals('456'));
        expect(match.pathParameters['postId'], equals('789'));
      });

      test('returns null for non-matching route', () {
        final match = RouteMatcher.match('/non-existent', testRoutes);
        expect(match, isNull);
      });

      test('handles query parameters', () {
        final match = RouteMatcher.match(
          '/settings',
          testRoutes,
          queryParameters: {'tab': 'notifications'},
        );
        expect(match, isNotNull);
        expect(match!.queryParameters['tab'], equals('notifications'));
      });

      test('normalizes paths correctly', () {
        final match1 = RouteMatcher.match('/settings/', testRoutes);
        final match2 = RouteMatcher.match('settings', testRoutes);
        expect(match1, isNotNull);
        expect(match2, isNotNull);
        expect(match1!.route.name, equals(match2!.route.name));
      });
    });

    group('buildPath', () {
      test('builds simple path', () {
        final route = testRoutes.firstWhere((r) => r.name == 'home');
        final path = RouteMatcher.buildPath(route, {});
        expect(path, equals('/'));
      });

      test('builds path with parameters', () {
        final route = testRoutes.firstWhere((r) => r.name == 'profile');
        final path = RouteMatcher.buildPath(route, {'id': '123'});
        expect(path, equals('/profile/123'));
      });

      test('builds path with query parameters', () {
        final route = testRoutes.firstWhere((r) => r.name == 'settings');
        final path = RouteMatcher.buildPath(
          route,
          {},
          queryParams: {'tab': 'notifications'},
        );
        expect(path, equals('/settings?tab=notifications'));
      });

      test('encodes special characters', () {
        final route = testRoutes.firstWhere((r) => r.name == 'profile');
        final path = RouteMatcher.buildPath(route, {'id': 'user name'});
        expect(path, contains('user%20name'));
      });
    });

    group('isMatch', () {
      test('returns true for exact match', () {
        expect(RouteMatcher.isMatch('/', '/'), isTrue);
        expect(RouteMatcher.isMatch('/settings', '/settings'), isTrue);
      });

      test('returns true for parameter match', () {
        expect(
          RouteMatcher.isMatch('/profile/123', '/profile/:id'),
          isTrue,
        );
      });

      test('returns false for non-match', () {
        expect(RouteMatcher.isMatch('/profile', '/settings'), isFalse);
        expect(
          RouteMatcher.isMatch('/profile/123/extra', '/profile/:id'),
          isFalse,
        );
      });
    });

    group('extractQueryParameters', () {
      test('extracts query parameters', () {
        final params = RouteMatcher.extractQueryParameters(
          '/settings?tab=notifications&theme=dark',
        );
        expect(params['tab'], equals('notifications'));
        expect(params['theme'], equals('dark'));
      });

      test('handles URL without query parameters', () {
        final params = RouteMatcher.extractQueryParameters('/settings');
        expect(params, isEmpty);
      });

      test('handles invalid URL gracefully', () {
        final params = RouteMatcher.extractQueryParameters(':::invalid:::');
        expect(params, isEmpty);
      });
    });
  });
}
