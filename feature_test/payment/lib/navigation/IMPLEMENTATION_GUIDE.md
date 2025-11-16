# Navigation System - Implementation Guide

This guide walks you through implementing the Navigation System in your Flutter app step by step.

## Table of Contents

1. [Basic Setup](#basic-setup)
2. [Defining Routes](#defining-routes)
3. [Setting Up Navigation Service](#setting-up-navigation-service)
4. [Implementing Guards](#implementing-guards)
5. [Deep Linking](#deep-linking)
6. [Tab Navigation](#tab-navigation)
7. [Nested Navigation](#nested-navigation)
8. [Testing](#testing)

---

## Basic Setup

### Step 1: Import the Package

```dart
import 'package:reuablewidgets/features/navigation/navigation.dart';
```

### Step 2: Create Your App Structure

```dart
class MyApp extends StatefulWidget {
  const MyApp({super.key});

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
    _setupNavigation();
  }

  void _setupNavigation() {
    // We'll implement this next
  }

  @override
  void dispose() {
    _routerDelegate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'My App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeInformationParser,
    );
  }
}
```

---

## Defining Routes

### Basic Route

```dart
RouteConfig.route(
  name: 'home',
  path: '/',
  builder: (context, params) => const HomePage(),
)
```

### Route with Parameters

```dart
RouteConfig.route(
  name: 'user-profile',
  path: '/user/:id',
  builder: (context, params) {
    final userId = params['id'] as String;
    return UserProfilePage(userId: userId);
  },
)
```

### Route with Multiple Parameters

```dart
RouteConfig.route(
  name: 'blog-post',
  path: '/blog/:category/:postId',
  builder: (context, params) {
    final category = params['category'] as String;
    final postId = params['postId'] as String;
    return BlogPostPage(
      category: category,
      postId: postId,
    );
  },
)
```

### Protected Route

```dart
RouteConfig.route(
  name: 'settings',
  path: '/settings',
  builder: (context, params) => const SettingsPage(),
  requiresAuth: true,
  guards: ['auth'],
)
```

### Route with Custom Transition

```dart
RouteConfig.withTransition(
  name: 'modal-page',
  path: '/modal',
  builder: (context, params) => const ModalPage(),
  transition: RouteTransition.slideFromBottom,
  duration: const Duration(milliseconds: 400),
)
```

### Dialog Route

```dart
RouteConfig.dialog(
  name: 'confirm-dialog',
  path: '/confirm',
  builder: (context, params) => const ConfirmDialog(),
)
```

### Route with Children (Nested)

```dart
RouteConfig.parent(
  name: 'dashboard',
  path: '/dashboard',
  builder: (context, params) => const DashboardPage(),
  children: [
    AppRoute(
      name: 'dashboard-overview',
      path: '/dashboard/overview',
      builder: (context, params) => const OverviewPage(),
    ),
    AppRoute(
      name: 'dashboard-analytics',
      path: '/dashboard/analytics',
      builder: (context, params) => const AnalyticsPage(),
    ),
  ],
)
```

### Complete Route List Example

```dart
List<AppRoute> _createRoutes() {
  return [
    // Public routes
    RouteConfig.route(
      name: 'home',
      path: '/',
      builder: (context, params) => const HomePage(),
    ),
    RouteConfig.route(
      name: 'login',
      path: '/login',
      builder: (context, params) => const LoginPage(),
    ),
    RouteConfig.route(
      name: 'signup',
      path: '/signup',
      builder: (context, params) => const SignUpPage(),
    ),

    // Protected routes
    RouteConfig.route(
      name: 'profile',
      path: '/profile',
      builder: (context, params) => const ProfilePage(),
      requiresAuth: true,
      guards: ['auth'],
    ),
    RouteConfig.route(
      name: 'settings',
      path: '/settings',
      builder: (context, params) => const SettingsPage(),
      requiresAuth: true,
      guards: ['auth'],
    ),

    // Admin routes
    RouteConfig.route(
      name: 'admin',
      path: '/admin',
      builder: (context, params) => const AdminPage(),
      requiresAuth: true,
      guards: ['auth', 'admin'],
      meta: {'roles': ['admin']},
    ),

    // Dynamic routes
    RouteConfig.route(
      name: 'user-profile',
      path: '/user/:id',
      builder: (context, params) => UserProfilePage(
        userId: params['id'] as String,
      ),
    ),
    RouteConfig.route(
      name: 'post-details',
      path: '/post/:id',
      builder: (context, params) => PostDetailsPage(
        postId: params['id'] as String,
      ),
    ),
  ];
}
```

---

## Setting Up Navigation Service

### Complete Setup

```dart
void _setupNavigation() {
  final routes = _createRoutes();

  // 1. Create Navigation Service
  _navigationService = NavigationService(
    navigatorKey: _navigatorKey,
    routes: routes,
  );

  // 2. Create Guards (we'll cover this next)
  final guards = _createGuards();

  // 3. Create 404 Route
  final notFoundRoute = AppRoute(
    name: '404',
    path: '/404',
    builder: (context, params) => const NotFoundPage(),
  );

  // 4. Create Router Delegate
  _routerDelegate = AppRouterDelegate(
    routes: routes,
    navigatorKey: _navigatorKey,
    guards: guards,
    navigationService: _navigationService,
    notFoundRoute: notFoundRoute,
    defaultRoute: '/',
  );

  // 5. Create Route Information Parser
  _routeInformationParser = const AppRouteInformationParser();
}
```

### Making Navigation Service Available App-Wide

#### Option 1: Using Provider

```dart
// pubspec.yaml
dependencies:
  provider: ^6.0.0

// In your app
class MyApp extends StatefulWidget {
  // ... existing code
}

class _MyAppState extends State<MyApp> {
  // ... existing fields

  @override
  Widget build(BuildContext context) {
    return Provider<NavigationService>.value(
      value: _navigationService,
      child: MaterialApp.router(
        routerDelegate: _routerDelegate,
        routeInformationParser: _routeInformationParser,
      ),
    );
  }
}

// Usage in widgets
final navService = Provider.of<NavigationService>(context, listen: false);
await navService.navigateTo('profile');
```

#### Option 2: Using GetIt (Dependency Injection)

```dart
// setup.dart
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Register navigation service
  getIt.registerLazySingleton<NavigationService>(
    () => NavigationService(
      navigatorKey: GlobalKey<NavigatorState>(),
      routes: createRoutes(),
    ),
  );
}

// main.dart
void main() {
  setupDependencies();
  runApp(MyApp());
}

// Usage anywhere
final navService = getIt<NavigationService>();
await navService.navigateTo('profile');
```

#### Option 3: Using Riverpod

```dart
// providers.dart
final navigationServiceProvider = Provider<NavigationService>((ref) {
  return NavigationService(
    navigatorKey: GlobalKey<NavigatorState>(),
    routes: createRoutes(),
  );
});

// Usage
final navService = ref.read(navigationServiceProvider);
await navService.navigateTo('profile');
```

---

## Implementing Guards

### Authentication Guard

```dart
class AuthGuard extends NavigationGuard {
  final Future<bool> Function() isAuthenticated;
  final String loginRoute;

  AuthGuard({
    required this.isAuthenticated,
    this.loginRoute = '/login',
  });

  @override
  String get name => 'auth';

  @override
  Future<GuardResult> canNavigate(
    RouteMatch match,
    Map<String, dynamic> context,
  ) async {
    // Check if route requires authentication
    if (!match.route.requiresAuth) {
      return GuardResult.allow();
    }

    // Check authentication status
    final isAuth = await isAuthenticated();

    if (!isAuth) {
      // Redirect to login with return URL
      return GuardResult.redirect(
        loginRoute,
        data: {'returnUrl': match.matchedPath},
        message: 'Please login to continue',
      );
    }

    return GuardResult.allow();
  }

  @override
  Future<void> onNavigationComplete(RouteMatch match) async {
    // Optional: Track navigation events
    print('Navigated to: ${match.route.name}');
  }
}
```

### Role-Based Guard

```dart
class AdminGuard extends NavigationGuard {
  final Future<String> Function() getUserRole;

  AdminGuard({required this.getUserRole});

  @override
  String get name => 'admin';

  @override
  Future<GuardResult> canNavigate(
    RouteMatch match,
    Map<String, dynamic> context,
  ) async {
    final role = await getUserRole();

    if (role != 'admin') {
      return GuardResult.redirect(
        '/unauthorized',
        message: 'Admin access required',
      );
    }

    return GuardResult.allow();
  }
}
```

### Custom Guard Example

```dart
class NetworkGuard extends NavigationGuard {
  final Future<bool> Function() hasNetwork;

  NetworkGuard({required this.hasNetwork});

  @override
  String get name => 'network';

  @override
  Future<GuardResult> canNavigate(
    RouteMatch match,
    Map<String, dynamic> context,
  ) async {
    final hasConnection = await hasNetwork();

    if (!hasConnection && match.route.meta['requiresNetwork'] == true) {
      return GuardResult.deny('No internet connection');
    }

    return GuardResult.allow();
  }
}
```

### Registering Guards

```dart
Map<String, NavigationGuard> _createGuards() {
  return {
    'auth': AuthGuard(
      isAuthenticated: () async {
        // Your auth check logic
        final authService = getIt<AuthService>();
        return authService.isAuthenticated;
      },
      loginRoute: '/login',
    ),
    'admin': AdminGuard(
      getUserRole: () async {
        final authService = getIt<AuthService>();
        return authService.userRole;
      },
    ),
    'network': NetworkGuard(
      hasNetwork: () async {
        final connectivity = getIt<ConnectivityService>();
        return connectivity.hasConnection;
      },
    ),
  };
}
```

---

## Deep Linking

### Setup Deep Linking

```dart
class _MyAppState extends State<MyApp> {
  late DeepLinkHandler _deepLinkHandler;

  @override
  void initState() {
    super.initState();
    _setupNavigation();
    _setupDeepLinking();
  }

  void _setupDeepLinking() {
    _deepLinkHandler = DeepLinkHandler(
      navigationService: _navigationService,
      routes: _createRoutes(),
    );

    // Initialize
    _deepLinkHandler.initialize();

    // Listen to deep links
    _deepLinkHandler.deepLinkStream.listen((uri) {
      print('Received deep link: $uri');
      // Handle custom logic if needed
    });
  }

  @override
  void dispose() {
    _deepLinkHandler.dispose();
    super.dispose();
  }
}
```

### Platform Configuration

#### Android (android/app/src/main/AndroidManifest.xml)

```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />

    <!-- HTTP and HTTPS -->
    <data android:scheme="https" android:host="yourdomain.com" />
    <data android:scheme="http" android:host="yourdomain.com" />

    <!-- Custom scheme -->
    <data android:scheme="myapp" />
</intent-filter>
```

#### iOS (ios/Runner/Info.plist)

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>com.yourdomain.app</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>myapp</string>
        </array>
    </dict>
</array>
```

### Testing Deep Links

```bash
# Android
adb shell am start -W -a android.intent.action.VIEW \
  -d "myapp://profile/123" com.yourdomain.app

# iOS (Simulator)
xcrun simctl openurl booted "myapp://profile/123"
```

---

## Tab Navigation

### Basic Tab Setup

```dart
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      TabItem(
        id: 'feed',
        label: 'Feed',
        icon: Icons.home,
        selectedIcon: Icons.home_filled,
        routes: _createFeedRoutes(),
        initialRoute: '/feed',
      ),
      TabItem(
        id: 'search',
        label: 'Search',
        icon: Icons.search,
        routes: _createSearchRoutes(),
        initialRoute: '/search',
      ),
      TabItem(
        id: 'profile',
        label: 'Profile',
        icon: Icons.person_outline,
        selectedIcon: Icons.person,
        routes: _createProfileRoutes(),
        initialRoute: '/profile',
      ),
    ];

    return TabNavigator(
      tabs: tabs,
      preserveState: true,
    );
  }

  List<AppRoute> _createFeedRoutes() {
    return [
      AppRoute(
        name: 'feed',
        path: '/feed',
        builder: (_, __) => const FeedPage(),
      ),
      AppRoute(
        name: 'feed-detail',
        path: '/feed/:id',
        builder: (context, params) => FeedDetailPage(
          id: params['id'] as String,
        ),
      ),
    ];
  }

  // ... similar for other tabs
}
```

---

## Nested Navigation

### Drawer with Nested Navigation

```dart
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Text('Menu'),
            ),
            ListTile(
              title: Text('Overview'),
              onTap: () {
                Navigator.pop(context);
                // Navigate within nested navigator
              },
            ),
            ListTile(
              title: Text('Analytics'),
              onTap: () {
                Navigator.pop(context);
                // Navigate within nested navigator
              },
            ),
          ],
        ),
      ),
      body: NestedNavigator(
        routes: _createDashboardRoutes(),
        initialRoute: '/dashboard/overview',
      ),
    );
  }
}
```

---

## Testing

### Unit Tests

```dart
void main() {
  group('NavigationService', () {
    late NavigationService service;

    setUp(() {
      service = NavigationService(
        navigatorKey: GlobalKey<NavigatorState>(),
        routes: testRoutes,
      );
    });

    test('builds route match correctly', () {
      final match = service.buildRouteMatch(
        'profile',
        pathParams: {'id': '123'},
      );

      expect(match, isNotNull);
      expect(match!.pathParameters['id'], equals('123'));
    });
  });
}
```

### Widget Tests

```dart
testWidgets('navigation works', (tester) async {
  await tester.pumpWidget(MyApp());

  // Find and tap button
  final button = find.text('Go to Profile');
  await tester.tap(button);
  await tester.pumpAndSettle();

  // Verify navigation
  expect(find.text('Profile Page'), findsOneWidget);
});
```

---

## Best Practices

1. **Route Names** - Use consistent naming (e.g., `'user-profile'`, `'post-details'`)
2. **Path Parameters** - Use descriptive names (`:userId` not `:id`)
3. **Guards** - Keep guard logic simple and focused
4. **Error Handling** - Always handle navigation errors
5. **Deep Links** - Test all deep link scenarios
6. **State Management** - Integrate with your state management solution
7. **Testing** - Write tests for critical navigation flows

---

## Next Steps

- Review the [Usage Guide](./USAGE_GUIDE.md) for common patterns
- Check [API Reference](./API_REFERENCE.md) for detailed API docs
- See [examples](./examples/) for complete working examples

---

**Happy Navigating! 🚀**
