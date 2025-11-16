import 'package:flutter/material.dart';
import '../navigation.dart';

/// Example app demonstrating all features of the Navigation System
///
/// This example shows:
/// - Basic routing
/// - Route parameters
/// - Query parameters
/// - Navigation guards
/// - Nested navigation
/// - Tab navigation
/// - Deep linking
/// - Custom transitions
class NavigationExampleApp extends StatefulWidget {
  const NavigationExampleApp({super.key});

  @override
  State<NavigationExampleApp> createState() => _NavigationExampleAppState();
}

class _NavigationExampleAppState extends State<NavigationExampleApp> {
  late final AppRouterDelegate _routerDelegate;
  late final AppRouteInformationParser _routeInformationParser;
  late final NavigationService _navigationService;
  late final DeepLinkHandler _deepLinkHandler;

  final _navigatorKey = GlobalKey<NavigatorState>();

  // Simulated auth state
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _initializeNavigation();
  }

  void _initializeNavigation() {
    final routes = _createRoutes();

    // Create navigation service
    _navigationService = NavigationService(
      navigatorKey: _navigatorKey,
      routes: routes,
    );

    // Create guards
    final authGuard = AuthGuard(
      isAuthenticated: () async => _isAuthenticated,
      loginRoute: '/login',
    );

    // Create router delegate
    _routerDelegate = AppRouterDelegate(
      routes: routes,
      navigatorKey: _navigatorKey,
      guards: {'auth': authGuard},
      navigationService: _navigationService,
      notFoundRoute: _create404Route(),
    );

    // Create route information parser
    _routeInformationParser = const AppRouteInformationParser();

    // Initialize deep linking
    _deepLinkHandler = DeepLinkHandler(
      navigationService: _navigationService,
      routes: routes,
    );
    _deepLinkHandler.initialize();
  }

  List<AppRoute> _createRoutes() {
    return [
      // Home route
      RouteConfig.route(
        name: 'home',
        path: '/',
        builder: (context, params) => const HomePage(),
      ),

      // Login route
      RouteConfig.route(
        name: 'login',
        path: '/login',
        builder: (context, params) => LoginPage(
          onLogin: () {
            setState(() => _isAuthenticated = true);
            _navigationService.navigateTo('home');
          },
        ),
      ),

      // Profile route (requires auth, has parameter)
      RouteConfig.route(
        name: 'profile',
        path: '/profile/:id',
        builder: (context, params) => ProfilePage(
          userId: params['id'] as String,
        ),
        requiresAuth: true,
        guards: ['auth'],
      ),

      // Settings route with custom transition
      RouteConfig.withTransition(
        name: 'settings',
        path: '/settings',
        builder: (context, params) => const SettingsPage(),
        transition: RouteTransition.slideFromBottom,
      ),

      // Details route with fade transition
      RouteConfig.withTransition(
        name: 'details',
        path: '/details/:itemId',
        builder: (context, params) => DetailsPage(
          itemId: params['itemId'] as String,
        ),
        transition: RouteTransition.fade,
      ),

      // Tab navigation route
      RouteConfig.route(
        name: 'tabs',
        path: '/tabs',
        builder: (context, params) => const TabsPage(),
      ),

      // Nested navigation example
      RouteConfig.parent(
        name: 'shop',
        path: '/shop',
        builder: (context, params) => const ShopPage(),
        children: [
          AppRoute(
            name: 'shop-products',
            path: '/shop/products',
            builder: (context, params) => const ProductsPage(),
          ),
          AppRoute(
            name: 'shop-cart',
            path: '/shop/cart',
            builder: (context, params) => const CartPage(),
          ),
        ],
      ),
    ];
  }

  AppRoute _create404Route() {
    return AppRoute(
      name: '404',
      path: '/404',
      builder: (context, params) => const NotFoundPage(),
    );
  }

  @override
  void dispose() {
    _routerDelegate.dispose();
    _deepLinkHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Navigation Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeInformationParser,
    );
  }
}

// Example pages

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to Navigation Example!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final service = NavigationService(
                  navigatorKey: GlobalKey<NavigatorState>(),
                  routes: [],
                );
                service.navigateTo('profile', pathParams: {'id': '123'});
              },
              child: const Text('Go to Profile'),
            ),
            ElevatedButton(
              onPressed: () {
                final service = NavigationService(
                  navigatorKey: GlobalKey<NavigatorState>(),
                  routes: [],
                );
                service.navigateTo('settings');
              },
              child: const Text('Go to Settings'),
            ),
            ElevatedButton(
              onPressed: () {
                final service = NavigationService(
                  navigatorKey: GlobalKey<NavigatorState>(),
                  routes: [],
                );
                service.navigateTo('tabs');
              },
              child: const Text('Go to Tabs'),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  final VoidCallback onLogin;

  const LoginPage({super.key, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Please log in to continue'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onLogin,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  final String userId;

  const ProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Text('Profile for user: $userId'),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(
        child: Text('Settings Page'),
      ),
    );
  }
}

class DetailsPage extends StatelessWidget {
  final String itemId;

  const DetailsPage({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Details')),
      body: Center(
        child: Text('Details for item: $itemId'),
      ),
    );
  }
}

class TabsPage extends StatelessWidget {
  const TabsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      TabItem(
        id: 'home',
        label: 'Home',
        icon: Icons.home,
        routes: [
          AppRoute(
            name: 'tab-home',
            path: '/tab-home',
            builder: (_, __) => const Center(child: Text('Home Tab')),
          ),
        ],
        initialRoute: '/tab-home',
      ),
      TabItem(
        id: 'search',
        label: 'Search',
        icon: Icons.search,
        routes: [
          AppRoute(
            name: 'tab-search',
            path: '/tab-search',
            builder: (_, __) => const Center(child: Text('Search Tab')),
          ),
        ],
        initialRoute: '/tab-search',
      ),
      TabItem(
        id: 'profile',
        label: 'Profile',
        icon: Icons.person,
        routes: [
          AppRoute(
            name: 'tab-profile',
            path: '/tab-profile',
            builder: (_, __) => const Center(child: Text('Profile Tab')),
          ),
        ],
        initialRoute: '/tab-profile',
      ),
    ];

    return TabNavigator(tabs: tabs);
  }
}

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shop')),
      body: const Center(
        child: Text('Shop - Nested navigation example'),
      ),
    );
  }
}

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: const Center(
        child: Text('Products List'),
      ),
    );
  }
}

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: const Center(
        child: Text('Shopping Cart'),
      ),
    );
  }
}

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('404')),
      body: const Center(
        child: Text('Page not found'),
      ),
    );
  }
}
