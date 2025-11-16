import 'package:flutter/foundation.dart';
import 'app_route.dart';

/// Represents a page in the navigation stack
@immutable
class NavigationPage {
  /// The route configuration
  final AppRoute route;

  /// Path parameters for this page
  final Map<String, dynamic> pathParameters;

  /// Query parameters for this page
  final Map<String, String> queryParameters;

  /// Unique key for this page
  final String key;

  /// Additional arguments passed to the page
  final Object? arguments;

  const NavigationPage({
    required this.route,
    required this.key,
    this.pathParameters = const {},
    this.queryParameters = const {},
    this.arguments,
  });

  NavigationPage copyWith({
    AppRoute? route,
    Map<String, dynamic>? pathParameters,
    Map<String, String>? queryParameters,
    String? key,
    Object? arguments,
  }) {
    return NavigationPage(
      route: route ?? this.route,
      pathParameters: pathParameters ?? this.pathParameters,
      queryParameters: queryParameters ?? this.queryParameters,
      key: key ?? this.key,
      arguments: arguments ?? this.arguments,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NavigationPage &&
          runtimeType == other.runtimeType &&
          key == other.key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() =>
      'NavigationPage(route: ${route.name}, key: $key)';
}

/// Represents the current navigation stack
@immutable
class NavigationStack {
  /// All pages in the current stack
  final List<NavigationPage> pages;

  /// The current active page (last in stack)
  NavigationPage? get current =>
      pages.isEmpty ? null : pages.last;

  /// Whether the stack is empty
  bool get isEmpty => pages.isEmpty;

  /// Whether the stack has items
  bool get isNotEmpty => pages.isNotEmpty;

  /// The size of the stack
  int get length => pages.length;

  const NavigationStack({
    this.pages = const [],
  });

  /// Creates a stack with a single page
  factory NavigationStack.single(NavigationPage page) {
    return NavigationStack(pages: [page]);
  }

  /// Pushes a new page onto the stack
  NavigationStack push(NavigationPage page) {
    return NavigationStack(
      pages: [...pages, page],
    );
  }

  /// Pops the top page from the stack
  NavigationStack pop() {
    if (pages.isEmpty) return this;
    return NavigationStack(
      pages: pages.sublist(0, pages.length - 1),
    );
  }

  /// Replaces the entire stack with new pages
  NavigationStack replace(List<NavigationPage> newPages) {
    return NavigationStack(pages: newPages);
  }

  /// Removes all pages until the predicate returns true
  NavigationStack popUntil(bool Function(NavigationPage) predicate) {
    final index = pages.lastIndexWhere(predicate);
    if (index == -1) return this;
    return NavigationStack(pages: pages.sublist(0, index + 1));
  }

  /// Removes all pages and pushes a new one
  NavigationStack pushAndRemoveUntil(
    NavigationPage page,
    bool Function(NavigationPage) predicate,
  ) {
    return popUntil(predicate).push(page);
  }

  /// Replaces the current page
  NavigationStack replaceCurrent(NavigationPage page) {
    if (pages.isEmpty) return NavigationStack.single(page);
    final newPages = [...pages];
    newPages[newPages.length - 1] = page;
    return NavigationStack(pages: newPages);
  }

  /// Gets a page by index
  NavigationPage? getPage(int index) {
    if (index < 0 || index >= pages.length) return null;
    return pages[index];
  }

  /// Finds a page by route name
  NavigationPage? findByRouteName(String name) {
    try {
      return pages.firstWhere((page) => page.route.name == name);
    } catch (_) {
      return null;
    }
  }

  /// Creates a copy with modified pages
  NavigationStack copyWith({
    List<NavigationPage>? pages,
  }) {
    return NavigationStack(
      pages: pages ?? this.pages,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NavigationStack &&
          runtimeType == other.runtimeType &&
          listEquals(pages, other.pages);

  @override
  int get hashCode => pages.hashCode;

  @override
  String toString() {
    return 'NavigationStack(pages: ${pages.map((p) => p.route.name).join(' -> ')})';
  }
}
