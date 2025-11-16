# Navigation System Package

A comprehensive, production-grade navigation system for Flutter applications built on top of Navigator 2.0 (Router API).

## 🚀 Features

- **Declarative Routing** - Define routes with a clean, declarative syntax
- **Type-Safe Navigation** - Full null-safety support with type-safe parameters
- **Deep Linking** - Built-in support for deep links and universal links
- **Navigation Guards** - Protect routes with authentication and authorization
- **Nested Navigation** - Support for complex nested navigation scenarios
- **Tab Navigation** - Built-in tab navigation with independent stacks
- **Custom Transitions** - Easily add custom page transitions
- **URL Support** - Full URL and query parameter support
- **Programmatic API** - Clean imperative API alongside declarative routing
- **Well-Tested** - Comprehensive unit and widget tests
- **Production-Ready** - Battle-tested patterns and best practices

## 📦 Installation

This is a feature module in the `reusablewidgets` package. Import it in your app:

```dart
import 'package:reuablewidgets/features/navigation/navigation.dart';
```

## 🎯 Quick Start

### 1. Define Routes

```dart
final routes = [
  // Simple route
  RouteConfig.route(
    name: 'home',
    path: '/',
    builder: (context, params) => HomePage(),
  ),

  // Route with parameters
  RouteConfig.route(
    name: 'profile',
    path: '/profile/:id',
    builder: (context, params) => ProfilePage(
      userId: params['id'] as String,
    ),
  ),

  // Protected route
  RouteConfig.route(
    name: 'settings',
    path: '/settings',
    builder: (context, params) => SettingsPage(),
    requiresAuth: true,
    guards: ['auth'],
  ),

  // Route with custom transition
  RouteConfig.withTransition(
    name: 'details',
    path: '/details/:id',
    builder: (context, params) => DetailsPage(id: params['id']),
    transition: RouteTransition.fade,
  ),
];
```

### 2. Setup Navigation

```dart
class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppRouterDelegate _routerDelegate;
  late final AppRouteInformationParser _routeInformationParser;
  late final NavigationService _navigationService;

  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

    // Create navigation service
    _navigationService = NavigationService(
      navigatorKey: _navigatorKey,
      routes: routes,
    );

    // Create auth guard
    final authGuard = AuthGuard(
      isAuthenticated: () async => await checkAuth(),
      loginRoute: '/login',
    );

    // Create router delegate
    _routerDelegate = AppRouterDelegate(
      routes: routes,
      navigatorKey: _navigatorKey,
      guards: {'auth': authGuard},
      navigationService: _navigationService,
    );

    // Create parser
    _routeInformationParser = const AppRouteInformationParser();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeInformationParser,
    );
  }
}
```

### 3. Navigate Programmatically

```dart
// Inject or access navigation service
final navService = NavigationService(...);

// Navigate to named route
await navService.navigateTo('profile', pathParams: {'id': '123'});

// Navigate with query parameters
await navService.navigateTo(
  'search',
  queryParams: {'q': 'flutter', 'sort': 'recent'},
);

// Replace current route
await navService.replace('login');

// Pop back
navService.pop();

// Pop with result
navService.pop('result data');

// Navigate and clear stack
await navService.navigateAndRemoveUntil('home');
```

## 📚 Core Concepts

### Routes

Routes define the navigation structure of your app. Each route has:

- **name** - Unique identifier
- **path** - URL pattern (supports parameters like `/user/:id`)
- **builder** - Function that builds the page widget
- **requiresAuth** - Whether authentication is required
- **guards** - List of guard names to apply
- **meta** - Additional metadata
- **transitionBuilder** - Custom transition animation

### Navigation Service

The `NavigationService` provides an imperative API for navigation:

```dart
final service = NavigationService(
  navigatorKey: navigatorKey,
  routes: routes,
);

// Navigate
service.navigateTo('routeName');

// Pop
service.pop();

// Show dialog
service.showDialog(builder: (context) => MyDialog());

// Show bottom sheet
service.showBottomSheet(builder: (context) => MySheet());

// Show snackbar
service.showSnackBar(message: 'Hello!');
```

### Navigation Guards

Guards protect routes and can redirect or deny navigation:

```dart
class AuthGuard extends NavigationGuard {
  @override
  String get name => 'auth';

  @override
  Future<GuardResult> canNavigate(
    RouteMatch match,
    Map<String, dynamic> context,
  ) async {
    final isAuth = await checkAuthentication();

    if (!isAuth && match.route.requiresAuth) {
      return GuardResult.redirect('/login');
    }

    return GuardResult.allow();
  }
}
```

### Nested Navigation

Support for nested navigators (tabs, drawers, etc.):

```dart
NestedNavigator(
  routes: nestedRoutes,
  initialRoute: '/nested-home',
)
```

### Tab Navigation

Built-in tab navigation with independent stacks:

```dart
TabNavigator(
  tabs: [
    TabItem(
      id: 'home',
      label: 'Home',
      icon: Icons.home,
      routes: homeRoutes,
      initialRoute: '/home',
    ),
    TabItem(
      id: 'profile',
      label: 'Profile',
      icon: Icons.person,
      routes: profileRoutes,
      initialRoute: '/profile',
    ),
  ],
)
```

### Deep Linking

Handle deep links and universal links:

```dart
final deepLinkHandler = DeepLinkHandler(
  navigationService: navService,
  routes: routes,
);

await deepLinkHandler.initialize();

// Listen to deep links
deepLinkHandler.deepLinkStream.listen((uri) {
  print('Deep link received: $uri');
});
```

## 🎨 Custom Transitions

Built-in transitions:

- `RouteTransition.fade` - Fade in/out
- `RouteTransition.slide` - Slide from right
- `RouteTransition.slideFromBottom` - Slide from bottom
- `RouteTransition.slideFromTop` - Slide from top
- `RouteTransition.slideFromLeft` - Slide from left
- `RouteTransition.scale` - Scale animation
- `RouteTransition.rotation` - Rotation animation
- `RouteTransition.none` - No animation

Or create custom transitions:

```dart
AppRoute(
  name: 'custom',
  path: '/custom',
  builder: (context, params) => CustomPage(),
  transitionBuilder: (context, animation, secondaryAnimation, child) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: child,
      ),
    );
  },
)
```

## 📖 Documentation

- [Implementation Guide](./IMPLEMENTATION_GUIDE.md) - Step-by-step setup guide
- [Usage Guide](./USAGE_GUIDE.md) - Common patterns and examples
- [API Reference](./API_REFERENCE.md) - Complete API documentation

## ✅ Testing

Run tests for this feature:

```bash
flutter test lib/features/navigation/tests/
```

## 🔧 Advanced Usage

### Route Parameters

```dart
// Define route with parameters
RouteConfig.route(
  name: 'post',
  path: '/user/:userId/post/:postId',
  builder: (context, params) => PostPage(
    userId: params['userId'],
    postId: params['postId'],
  ),
);

// Navigate with parameters
navService.navigateTo(
  'post',
  pathParams: {'userId': '123', 'postId': '456'},
);
```

### Query Parameters

```dart
// Navigate with query params
navService.navigateTo(
  'search',
  queryParams: {'q': 'flutter', 'page': '1'},
);

// Access in builder
RouteConfig.route(
  name: 'search',
  path: '/search',
  builder: (context, params) {
    final query = params['q'];
    final page = params['page'];
    return SearchPage(query: query, page: page);
  },
);
```

### Navigation History

```dart
// Get current route
final current = navService.currentRoute;

// Get previous route
final previous = navService.previousRoute;

// Get full history
final history = navService.history;
```

### Custom Guards

```dart
class RoleGuard extends NavigationGuard {
  final List<String> allowedRoles;

  RoleGuard(this.allowedRoles);

  @override
  String get name => 'role';

  @override
  Future<GuardResult> canNavigate(
    RouteMatch match,
    Map<String, dynamic> context,
  ) async {
    final userRole = await getUserRole();

    if (!allowedRoles.contains(userRole)) {
      return GuardResult.redirect('/unauthorized');
    }

    return GuardResult.allow();
  }
}
```

## 🤝 Contributing

This is a reusable feature module. To improve it:

1. Make changes in `/lib/features/navigation/`
2. Add tests in `/lib/features/navigation/tests/`
3. Update documentation
4. Test thoroughly

## 📄 License

This feature is part of the reusablewidgets package.

## 🙋 Support

For issues or questions:
- Check the [documentation](./IMPLEMENTATION_GUIDE.md)
- Review the [examples](./examples/)
- Check existing tests for usage patterns

---

**Built with ❤️ using Flutter and Navigator 2.0**
