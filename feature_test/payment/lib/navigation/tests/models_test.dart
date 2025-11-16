import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../models/app_route.dart';
import '../models/navigation_stack.dart';
import '../models/route_information.dart';

void main() {
  group('Models', () {
    group('AppRoute', () {
      test('creates route correctly', () {
        final route = AppRoute(
          name: 'test',
          path: '/test',
          builder: (_, __) => const Placeholder(),
          requiresAuth: true,
          guards: ['auth'],
          meta: {'title': 'Test Page'},
        );

        expect(route.name, equals('test'));
        expect(route.path, equals('/test'));
        expect(route.requiresAuth, isTrue);
        expect(route.guards, contains('auth'));
        expect(route.meta['title'], equals('Test Page'));
      });

      test('copyWith works correctly', () {
        final route = AppRoute(
          name: 'test',
          path: '/test',
          builder: (_, __) => const Placeholder(),
        );

        final copied = route.copyWith(
          name: 'updated',
          requiresAuth: true,
        );

        expect(copied.name, equals('updated'));
        expect(copied.path, equals('/test'));
        expect(copied.requiresAuth, isTrue);
      });

      test('equality works correctly', () {
        final route1 = AppRoute(
          name: 'test',
          path: '/test',
          builder: (_, __) => const Placeholder(),
        );

        final route2 = AppRoute(
          name: 'test',
          path: '/test',
          builder: (_, __) => const Placeholder(),
        );

        final route3 = AppRoute(
          name: 'different',
          path: '/different',
          builder: (_, __) => const Placeholder(),
        );

        expect(route1, equals(route2));
        expect(route1, isNot(equals(route3)));
      });
    });

    group('AppRouteInformation', () {
      test('creates from URI', () {
        final uri = Uri.parse('/test?key=value');
        final info = AppRouteInformation.fromUri(uri);

        expect(info.location, equals('/test'));
        expect(info.queryParameters['key'], equals('value'));
      });

      test('converts to URI', () {
        final info = AppRouteInformation(
          location: '/test',
          queryParameters: {'key': 'value'},
        );

        final uri = info.toUri();
        expect(uri.path, equals('/test'));
        expect(uri.queryParameters['key'], equals('value'));
      });

      test('copyWith works correctly', () {
        final info = AppRouteInformation(
          location: '/test',
          queryParameters: {'key': 'value'},
        );

        final copied = info.copyWith(
          location: '/updated',
        );

        expect(copied.location, equals('/updated'));
        expect(copied.queryParameters['key'], equals('value'));
      });
    });

    group('NavigationStack', () {
      late AppRoute testRoute;
      late NavigationPage testPage;

      setUp(() {
        testRoute = AppRoute(
          name: 'test',
          path: '/test',
          builder: (_, __) => const Placeholder(),
        );

        testPage = NavigationPage(
          route: testRoute,
          key: 'test_key',
        );
      });

      test('creates empty stack', () {
        const stack = NavigationStack();
        expect(stack.isEmpty, isTrue);
        expect(stack.isNotEmpty, isFalse);
        expect(stack.length, equals(0));
        expect(stack.current, isNull);
      });

      test('creates stack with single page', () {
        final stack = NavigationStack.single(testPage);
        expect(stack.isEmpty, isFalse);
        expect(stack.length, equals(1));
        expect(stack.current, equals(testPage));
      });

      test('push adds page to stack', () {
        const stack = NavigationStack();
        final newStack = stack.push(testPage);

        expect(newStack.length, equals(1));
        expect(newStack.current, equals(testPage));
        expect(stack.isEmpty, isTrue); // Original unchanged
      });

      test('pop removes page from stack', () {
        final stack = NavigationStack.single(testPage);
        final newStack = stack.pop();

        expect(newStack.isEmpty, isTrue);
        expect(stack.length, equals(1)); // Original unchanged
      });

      test('pop on empty stack returns empty', () {
        const stack = NavigationStack();
        final newStack = stack.pop();
        expect(newStack.isEmpty, isTrue);
      });

      test('replace changes all pages', () {
        final stack = NavigationStack.single(testPage);
        final newPage = NavigationPage(
          route: testRoute,
          key: 'new_key',
        );

        final newStack = stack.replace([newPage]);
        expect(newStack.length, equals(1));
        expect(newStack.current!.key, equals('new_key'));
      });

      test('replaceCurrent changes only current page', () {
        final page1 = NavigationPage(
          route: testRoute,
          key: 'page1',
        );
        final page2 = NavigationPage(
          route: testRoute,
          key: 'page2',
        );
        final page3 = NavigationPage(
          route: testRoute,
          key: 'page3',
        );

        final stack = NavigationStack(pages: [page1, page2]);
        final newStack = stack.replaceCurrent(page3);

        expect(newStack.length, equals(2));
        expect(newStack.pages[0].key, equals('page1'));
        expect(newStack.current!.key, equals('page3'));
      });

      test('findByRouteName finds correct page', () {
        final route1 = AppRoute(
          name: 'route1',
          path: '/route1',
          builder: (_, __) => const Placeholder(),
        );
        final route2 = AppRoute(
          name: 'route2',
          path: '/route2',
          builder: (_, __) => const Placeholder(),
        );

        final page1 = NavigationPage(route: route1, key: 'page1');
        final page2 = NavigationPage(route: route2, key: 'page2');

        final stack = NavigationStack(pages: [page1, page2]);

        expect(stack.findByRouteName('route1'), equals(page1));
        expect(stack.findByRouteName('route2'), equals(page2));
        expect(stack.findByRouteName('nonexistent'), isNull);
      });
    });
  });
}
