# Navigation System - Usage Guide

Common patterns and real-world examples for using the Navigation System.

## Table of Contents

1. [Common Navigation Patterns](#common-navigation-patterns)
2. [Authentication Flow](#authentication-flow)
3. [Deep Linking](#deep-linking)
4. [Error Handling](#error-handling)
5. [Advanced Patterns](#advanced-patterns)

---

## Common Navigation Patterns

### Basic Navigation

```dart
// Navigate to a route
await navService.navigateTo('home');

// Navigate with path parameters
await navService.navigateTo(
  'user-profile',
  pathParams: {'id': userId},
);

// Navigate with query parameters
await navService.navigateTo(
  'search',
  queryParams: {
    'q': 'flutter',
    'category': 'mobile',
    'page': '1',
  },
);

// Navigate with both
await navService.navigateTo(
  'product-details',
  pathParams: {'id': '123'},
  queryParams: {'variant': 'red'},
);
```

### Stack Management

```dart
// Replace current route
await navService.replace('login');

// Navigate and clear entire stack
await navService.navigateAndRemoveUntil('home');

// Navigate and clear until condition
await navService.navigateAndRemoveUntil(
  'dashboard',
  predicate: (route) => route.settings.name == 'home',
);

// Pop to specific route
navService.popUntil('home');

// Pop to root
navService.popToRoot();

// Pop with result
navService.pop({'success': true, 'data': userData});
```

### Checking Navigation State

```dart
// Check if can pop
if (navService.canPop()) {
  navService.pop();
} else {
  // Show exit confirmation
  final exit = await showExitDialog();
  if (exit) {
    SystemNavigator.pop();
  }
}

// Get current route
final current = navService.currentRoute;
print('Current: $current');

// Get previous route
final previous = navService.previousRoute;
print('Previous: $previous');

// Access navigation history
final history = navService.history;
print('History: $history');
```

---

## Authentication Flow

### Complete Auth Implementation

```dart
class AuthenticationFlow {
  final NavigationService navService;
  final AuthService authService;

  AuthenticationFlow({
    required this.navService,
    required this.authService,
  });

  // Login flow
  Future<void> login(String email, String password) async {
    try {
      // Attempt login
      final result = await authService.login(email, password);

      if (result.success) {
        // Get return URL from route params
        final returnUrl = _getReturnUrl();

        // Navigate to return URL or home
        if (returnUrl != null && returnUrl != '/login') {
          await navService.navigateTo(returnUrl);
        } else {
          await navService.navigateAndRemoveUntil('home');
        }
      } else {
        navService.showSnackBar(
          message: 'Login failed: ${result.error}',
        );
      }
    } catch (e) {
      navService.showSnackBar(message: 'An error occurred');
    }
  }

  // Logout flow
  Future<void> logout() async {
    await authService.logout();
    await navService.navigateAndRemoveUntil('login');
  }

  // Get return URL from current route
  String? _getReturnUrl() {
    // Implementation depends on how you pass return URL
    // Could be from route params or state management
    return null;
  }
}
```

### Protected Route Access

```dart
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final authService = getIt<AuthService>();
    final isAuth = await authService.isAuthenticated;

    if (!isAuth) {
      final navService = getIt<NavigationService>();
      await navService.navigateAndRemoveUntil('login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: ProfileContent(),
    );
  }
}
```

### Social Login Integration

```dart
Future<void> loginWithGoogle() async {
  try {
    final navService = getIt<NavigationService>();
    final authService = getIt<AuthService>();

    // Show loading
    navService.showDialog(
      builder: (context) => LoadingDialog(),
      barrierDismissible: false,
    );

    // Perform Google sign-in
    final result = await authService.signInWithGoogle();

    // Close loading
    navService.pop();

    if (result.success) {
      // Navigate to home
      await navService.navigateAndRemoveUntil('home');
    } else {
      navService.showSnackBar(message: result.error ?? 'Login failed');
    }
  } catch (e) {
    navService.showSnackBar(message: 'An error occurred');
  }
}
```

---

## Deep Linking

### Handling Deep Links

```dart
class DeepLinkingExample {
  final DeepLinkHandler deepLinkHandler;
  final NavigationService navService;

  DeepLinkingExample({
    required this.deepLinkHandler,
    required this.navService,
  });

  void setupDeepLinking() {
    // Listen to deep links
    deepLinkHandler.deepLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }

  Future<void> _handleDeepLink(Uri uri) async {
    // Example: myapp://profile/123?tab=posts
    final path = uri.path; // /profile/123
    final params = uri.queryParameters; // {tab: posts}

    // Parse and navigate
    if (path.startsWith('/profile/')) {
      final userId = path.split('/').last;
      await navService.navigateTo(
        'profile',
        pathParams: {'id': userId},
        queryParams: params,
      );
    } else if (path.startsWith('/post/')) {
      final postId = path.split('/').last;
      await navService.navigateTo(
        'post-details',
        pathParams: {'id': postId},
      );
    } else {
      // Handle unknown deep link
      await navService.navigateTo('home');
    }
  }

  // Create shareable deep links
  String createProfileLink(String userId) {
    return deepLinkHandler.createDeepLink(
      scheme: 'myapp',
      host: '',
      routePath: '/profile/$userId',
    );
  }

  String createPostLink(String postId, {String? comment}) {
    return deepLinkHandler.createDeepLink(
      scheme: 'myapp',
      host: '',
      routePath: '/post/$postId',
      queryParams: comment != null ? {'comment': comment} : null,
    );
  }
}
```

### Universal Links (HTTPS)

```dart
// Handle both custom scheme and HTTPS
Future<void> _handleIncomingLink(Uri uri) async {
  if (uri.scheme == 'https' && uri.host == 'yourdomain.com') {
    // Handle universal link
    await _handleWebLink(uri);
  } else if (uri.scheme == 'myapp') {
    // Handle custom scheme
    await _handleCustomScheme(uri);
  }
}

Future<void> _handleWebLink(Uri uri) async {
  // https://yourdomain.com/profile/123
  final path = uri.path;
  final segments = path.split('/').where((s) => s.isNotEmpty).toList();

  if (segments.isEmpty) {
    await navService.navigateTo('home');
    return;
  }

  switch (segments[0]) {
    case 'profile':
      if (segments.length > 1) {
        await navService.navigateTo(
          'profile',
          pathParams: {'id': segments[1]},
        );
      }
      break;
    case 'post':
      if (segments.length > 1) {
        await navService.navigateTo(
          'post-details',
          pathParams: {'id': segments[1]},
        );
      }
      break;
    default:
      await navService.navigateTo('home');
  }
}
```

---

## Error Handling

### Navigation Error Handling

```dart
Future<void> safeNavigate(
  String routeName, {
  Map<String, dynamic>? pathParams,
  Map<String, String>? queryParams,
}) async {
  try {
    final result = await navService.navigateTo(
      routeName,
      pathParams: pathParams,
      queryParams: queryParams,
    );

    if (!result.success) {
      // Handle navigation failure
      _handleNavigationError(result.error);
    }
  } catch (e) {
    // Handle exception
    _handleNavigationException(e);
  }
}

void _handleNavigationError(String? error) {
  navService.showSnackBar(
    message: error ?? 'Navigation failed',
    action: SnackBarAction(
      label: 'Dismiss',
      onPressed: () {},
    ),
  );
}

void _handleNavigationException(dynamic exception) {
  // Log error
  print('Navigation exception: $exception');

  // Show user-friendly message
  navService.showSnackBar(
    message: 'Something went wrong. Please try again.',
  );

  // Optionally navigate to error page
  navService.navigateTo('error');
}
```

### 404 Handling

```dart
// Define 404 route
final notFoundRoute = AppRoute(
  name: '404',
  path: '/404',
  builder: (context, params) => NotFoundPage(
    requestedPath: params['path'] as String?,
  ),
);

// Use in router delegate
_routerDelegate = AppRouterDelegate(
  routes: routes,
  notFoundRoute: notFoundRoute,
  // ...
);

// 404 Page
class NotFoundPage extends StatelessWidget {
  final String? requestedPath;

  const NotFoundPage({super.key, this.requestedPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '404 - Page Not Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (requestedPath != null) ...[
              SizedBox(height: 8),
              Text('Path: $requestedPath'),
            ],
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final navService = getIt<NavigationService>();
                navService.navigateTo('home');
              },
              child: Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Advanced Patterns

### Conditional Navigation

```dart
Future<void> navigateBasedOnUserRole() async {
  final authService = getIt<AuthService>();
  final role = await authService.getUserRole();

  switch (role) {
    case 'admin':
      await navService.navigateTo('admin-dashboard');
      break;
    case 'moderator':
      await navService.navigateTo('moderator-panel');
      break;
    case 'user':
      await navService.navigateTo('user-home');
      break;
    default:
      await navService.navigateTo('login');
  }
}
```

### Navigation with Confirmation

```dart
Future<void> navigateWithConfirmation(String routeName) async {
  final confirmed = await navService.showDialog<bool>(
    builder: (context) => AlertDialog(
      title: Text('Confirm Navigation'),
      content: Text('Unsaved changes will be lost. Continue?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Continue'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    await navService.navigateTo(routeName);
  }
}
```

### Programmatic Guard Bypass

```dart
// Sometimes you need to bypass guards programmatically
class NavigationHelper {
  final NavigationService navService;

  NavigationHelper(this.navService);

  Future<void> forceNavigate(String routeName) async {
    // Use direct navigation that bypasses guards
    final navigator = navService.navigator;
    if (navigator != null) {
      await navigator.pushNamed(routeName);
    }
  }
}
```

### Bottom Sheet Navigation

```dart
Future<void> showOptionsBottomSheet() async {
  final result = await navService.showBottomSheet<String>(
    builder: (context) => Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Edit Profile'),
            onTap: () => Navigator.pop(context, 'edit'),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () => Navigator.pop(context, 'settings'),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () => Navigator.pop(context, 'logout'),
          ),
        ],
      ),
    ),
  );

  if (result != null) {
    switch (result) {
      case 'edit':
        await navService.navigateTo('edit-profile');
        break;
      case 'settings':
        await navService.navigateTo('settings');
        break;
      case 'logout':
        await _handleLogout();
        break;
    }
  }
}
```

### Wizard/Multi-Step Flow

```dart
class OnboardingFlow {
  final NavigationService navService;
  int currentStep = 0;

  OnboardingFlow(this.navService);

  Future<void> start() async {
    await navService.navigateTo('onboarding-step-1');
  }

  Future<void> next() async {
    currentStep++;
    await navService.replace('onboarding-step-${currentStep + 1}');
  }

  Future<void> previous() async {
    if (currentStep > 0) {
      currentStep--;
      await navService.replace('onboarding-step-${currentStep + 1}');
    }
  }

  Future<void> complete() async {
    // Mark onboarding complete
    await saveOnboardingComplete();

    // Navigate to home and clear stack
    await navService.navigateAndRemoveUntil('home');
  }
}
```

### Navigation Analytics

```dart
class NavigationAnalytics {
  final AnalyticsService analyticsService;

  NavigationAnalytics(this.analyticsService);

  void trackNavigation(String routeName, {Map<String, dynamic>? params}) {
    analyticsService.logEvent(
      name: 'navigation',
      parameters: {
        'route_name': routeName,
        'timestamp': DateTime.now().toIso8601String(),
        ...?params,
      },
    );
  }

  void trackNavigationTime(String routeName, Duration duration) {
    analyticsService.logEvent(
      name: 'navigation_duration',
      parameters: {
        'route_name': routeName,
        'duration_ms': duration.inMilliseconds,
      },
    );
  }
}

// Usage with custom guard
class AnalyticsGuard extends NavigationGuard {
  final NavigationAnalytics analytics;

  AnalyticsGuard(this.analytics);

  @override
  String get name => 'analytics';

  @override
  Future<GuardResult> canNavigate(
    RouteMatch match,
    Map<String, dynamic> context,
  ) async {
    analytics.trackNavigation(
      match.route.name,
      params: match.pathParameters,
    );
    return GuardResult.allow();
  }
}
```

---

## Tips & Best Practices

### 1. Route Organization

```dart
// routes/routes.dart
class AppRoutes {
  static const home = '/';
  static const login = '/login';
  static const profile = '/profile/:id';
  static const settings = '/settings';

  // Nested routes
  static const dashboardOverview = '/dashboard/overview';
  static const dashboardAnalytics = '/dashboard/analytics';
}

// Usage
await navService.navigateTo(AppRoutes.profile, pathParams: {'id': userId});
```

### 2. Type-Safe Navigation

```dart
// Create extension methods for type safety
extension TypedNavigation on NavigationService {
  Future<void> goToProfile(String userId) {
    return navigateTo('profile', pathParams: {'id': userId});
  }

  Future<void> goToPost(String postId, {String? commentId}) {
    return navigateTo(
      'post-details',
      pathParams: {'id': postId},
      queryParams: commentId != null ? {'comment': commentId} : null,
    );
  }
}

// Usage
await navService.goToProfile('123');
await navService.goToPost('456', commentId: '789');
```

### 3. Navigation State Management

```dart
// Using Riverpod
final navigationHistoryProvider = StateProvider<List<String>>((ref) => []);

// Update on navigation
ref.read(navigationHistoryProvider.notifier).state = [
  ...ref.read(navigationHistoryProvider),
  routeName,
];
```

---

**For more examples, check the [examples](./examples/) directory!**
