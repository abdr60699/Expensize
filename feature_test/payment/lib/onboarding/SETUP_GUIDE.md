# Onboarding Module - Complete Setup Guide

Step-by-step guide to integrate the Onboarding module into any Flutter app.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quick Setup (5 minutes)](#quick-setup-5-minutes)
3. [Detailed Setup](#detailed-setup)
4. [Integration Patterns](#integration-patterns)
5. [Customization Guide](#customization-guide)
6. [Troubleshooting](#troubleshooting)
7. [Testing](#testing)

---

## Prerequisites

### What You Need

✅ Flutter SDK installed (3.0.0 or higher)
✅ Existing Flutter app or new Flutter project
✅ `shared_preferences` package (already in this project)

### Check Your Flutter Installation

```bash
flutter --version
flutter doctor
```

---

## Quick Setup (5 minutes)

### Step 1: Import the Module

Add this import to your Dart file:

```dart
import 'package:reuablewidgets/features/onboarding/onboarding.dart';
```

### Step 2: Initialize the Service

In your `main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:reuablewidgets/features/onboarding/onboarding.dart';

void main() async {
  // Required for async operations before runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize onboarding service
  final onboardingService = OnboardingService(version: '1.0.0');
  await onboardingService.initialize();

  // Check if user needs to see onboarding
  final showOnboarding = await onboardingService.shouldShowOnboarding();

  runApp(MyApp(showOnboarding: showOnboarding));
}
```

### Step 3: Show Onboarding or Home Screen

```dart
class MyApp extends StatelessWidget {
  final bool showOnboarding;

  const MyApp({required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: showOnboarding ? OnboardingFlow() : HomeScreen(),
    );
  }
}
```

### Step 4: Create Your Onboarding Flow

```dart
class OnboardingFlow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Define your pages
    final pages = [
      OnboardingPage.withIcon(
        title: 'Welcome',
        description: 'Welcome to our app!',
        icon: Icons.waving_hand,
        iconColor: Colors.blue,
      ),
      OnboardingPage.withIcon(
        title: 'Explore',
        description: 'Discover amazing features',
        icon: Icons.explore,
        iconColor: Colors.green,
      ),
      OnboardingPage.withIcon(
        title: 'Get Started',
        description: 'Let\'s begin!',
        icon: Icons.rocket_launch,
        iconColor: Colors.orange,
      ),
    ];

    // Create configuration
    final config = OnboardingConfig(
      pages: pages,
      onComplete: () {
        // User completed onboarding - go to home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      },
      onSkip: () {
        // User skipped - also go to home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      },
    );

    // Show onboarding screen
    return OnboardingScreen(config: config);
  }
}
```

### Step 5: Create Your Home Screen

```dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: Text('Welcome to the app!'),
      ),
    );
  }
}
```

**Done!** Your app now has onboarding. Run it:

```bash
flutter run
```

---

## Detailed Setup

### Option A: Show Onboarding on First Launch Only

This is the most common pattern - show onboarding once when the user first opens the app.

**Complete main.dart:**

```dart
import 'package:flutter/material.dart';
import 'package:reuablewidgets/features/onboarding/onboarding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize onboarding service with version
  final onboardingService = OnboardingService(version: '1.0.0');
  await onboardingService.initialize();

  runApp(MyApp(onboardingService: onboardingService));
}

class MyApp extends StatelessWidget {
  final OnboardingService onboardingService;

  const MyApp({required this.onboardingService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: AppInitializer(onboardingService: onboardingService),
    );
  }
}

class AppInitializer extends StatefulWidget {
  final OnboardingService onboardingService;

  const AppInitializer({required this.onboardingService});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final shouldShow = await widget.onboardingService.shouldShowOnboarding();

    if (mounted) {
      if (shouldShow) {
        // Show onboarding
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OnboardingFlow(
              onboardingService: widget.onboardingService,
            ),
          ),
        );
      } else {
        // Go directly to home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while checking
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
```

### Option B: Show Onboarding from Settings/Menu

Allow users to replay onboarding from a settings menu.

**In your settings screen:**

```dart
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('View Onboarding'),
            subtitle: Text('See the app intro again'),
            onTap: () => _showOnboarding(context),
          ),
          // Other settings...
        ],
      ),
    );
  }

  void _showOnboarding(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OnboardingFlow(
          // Don't pass service so it won't mark as completed
          onboardingService: null,
        ),
      ),
    );
  }
}
```

### Option C: Show Onboarding When App Updates

Show onboarding again when you release a major update with new features.

**Update version in main.dart when releasing:**

```dart
// Version 1.0.0 - initial release
final onboardingService = OnboardingService(version: '1.0.0');

// Version 2.0.0 - major update (users will see onboarding again)
final onboardingService = OnboardingService(version: '2.0.0');
```

### Option D: Conditional Onboarding

Show different onboarding based on user type or context.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final onboardingService = OnboardingService(version: '1.0.0');
  await onboardingService.initialize();

  // Check user status
  final isLoggedIn = await checkLoginStatus();

  runApp(MyApp(
    onboardingService: onboardingService,
    isLoggedIn: isLoggedIn,
  ));
}

class MyApp extends StatelessWidget {
  final OnboardingService onboardingService;
  final bool isLoggedIn;

  const MyApp({
    required this.onboardingService,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder<bool>(
        future: onboardingService.shouldShowOnboarding(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          final shouldShowOnboarding = snapshot.data!;

          // Decide which screen to show
          if (!isLoggedIn) {
            return LoginScreen();
          } else if (shouldShowOnboarding) {
            return OnboardingFlow(onboardingService: onboardingService);
          } else {
            return HomeScreen();
          }
        },
      ),
    );
  }
}
```

---

## Integration Patterns

### Pattern 1: Simple App (Recommended for Most Apps)

**File: lib/main.dart**

```dart
import 'package:flutter/material.dart';
import 'package:reuablewidgets/features/onboarding/onboarding.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_flow.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final onboardingService = OnboardingService(version: '1.0.0');
  await onboardingService.initialize();

  final showOnboarding = await onboardingService.shouldShowOnboarding();

  runApp(MyApp(showOnboarding: showOnboarding));
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;

  const MyApp({required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: showOnboarding ? OnboardingFlow() : HomeScreen(),
    );
  }
}
```

**File: lib/screens/onboarding_flow.dart**

```dart
import 'package:flutter/material.dart';
import 'package:reuablewidgets/features/onboarding/onboarding.dart';
import 'home_screen.dart';

class OnboardingFlow extends StatelessWidget {
  final OnboardingService? onboardingService;

  const OnboardingFlow({this.onboardingService});

  @override
  Widget build(BuildContext context) {
    final pages = [
      OnboardingPage.withIcon(
        title: 'Welcome',
        description: 'Welcome to our amazing app!',
        icon: Icons.waving_hand,
        iconColor: Colors.blue,
      ),
      OnboardingPage.withIcon(
        title: 'Features',
        description: 'Discover all the great features',
        icon: Icons.star,
        iconColor: Colors.amber,
      ),
      OnboardingPage.withIcon(
        title: 'Get Started',
        description: 'Let\'s begin your journey!',
        icon: Icons.rocket_launch,
        iconColor: Colors.green,
      ),
    ];

    final config = OnboardingConfig(
      pages: pages,
      onComplete: () => _navigateToHome(context),
      onSkip: () => _navigateToHome(context),
    );

    return OnboardingScreen(
      config: config,
      onboardingService: onboardingService,
    );
  }

  void _navigateToHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen()),
    );
  }
}
```

### Pattern 2: With Splash Screen

**File: lib/main.dart**

```dart
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
    );
  }
}
```

**File: lib/screens/splash_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'package:reuablewidgets/features/onboarding/onboarding.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Initialize your app (database, services, etc.)
    await Future.delayed(Duration(seconds: 2)); // Simulate loading

    // Initialize onboarding
    final onboardingService = OnboardingService(version: '1.0.0');
    await onboardingService.initialize();

    final showOnboarding = await onboardingService.shouldShowOnboarding();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => showOnboarding
              ? OnboardingFlow(onboardingService: onboardingService)
              : HomeScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlutterLogo(size: 100),
            SizedBox(height: 20),
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }
}
```

### Pattern 3: With State Management (Provider, Riverpod, Bloc)

**Using Provider example:**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reuablewidgets/features/onboarding/onboarding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final onboardingService = OnboardingService(version: '1.0.0');
  await onboardingService.initialize();

  runApp(
    MultiProvider(
      providers: [
        Provider<OnboardingService>.value(value: onboardingService),
        // Other providers...
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final onboardingService = context.read<OnboardingService>();

    return MaterialApp(
      home: FutureBuilder<bool>(
        future: onboardingService.shouldShowOnboarding(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          return snapshot.data!
              ? OnboardingFlow()
              : HomeScreen();
        },
      ),
    );
  }
}
```

---

## Customization Guide

### Creating Your Pages

#### Option 1: Using Icons (Recommended for Simple Apps)

```dart
OnboardingPage.withIcon(
  title: 'Fast & Secure',
  description: 'Your data is protected with encryption',
  icon: Icons.security,
  iconColor: Colors.blue,
  iconSize: 120, // Optional, default is 120
  backgroundColor: Colors.blue.shade50, // Optional
  textColor: Colors.black, // Optional
)
```

**Common Icons:**
- `Icons.waving_hand` - Welcome
- `Icons.security` - Security
- `Icons.speed` - Performance
- `Icons.favorite` - Favorites
- `Icons.notifications` - Notifications
- `Icons.explore` - Explore
- `Icons.star` - Features
- `Icons.rocket_launch` - Get Started

#### Option 2: Using Images

```dart
OnboardingPage.withImage(
  title: 'Beautiful Design',
  description: 'Modern and intuitive interface',
  imagePath: 'assets/images/onboarding1.png',
)
```

**Setup for images:**

1. Create `assets/images/` folder in your project
2. Add images to the folder
3. Update `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/images/
```

#### Option 3: Custom Widget

```dart
OnboardingPage.custom(
  widget: Container(
    padding: EdgeInsets.all(40),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Your custom layout
        Icon(Icons.check_circle, size: 100, color: Colors.green),
        SizedBox(height: 40),
        Text('Custom Page', style: TextStyle(fontSize: 28)),
        // Any widgets you want
      ],
    ),
  ),
)
```

### Styling Your Onboarding

#### Basic Styling

```dart
OnboardingConfig(
  pages: pages,

  // Button text
  skipButtonText: 'Skip',
  nextButtonText: 'Next',
  doneButtonText: 'Get Started',

  // Text styles
  titleTextStyle: TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  ),
  descriptionTextStyle: TextStyle(
    fontSize: 16,
    color: Colors.black54,
    height: 1.5,
  ),

  // Layout
  contentPadding: EdgeInsets.symmetric(horizontal: 32, vertical: 48),
  imageHeightRatio: 0.4, // 40% of screen for images
  imageTextSpacing: 32, // Space between image and text
)
```

#### Background Gradient

```dart
OnboardingConfig(
  pages: pages,
  backgroundGradientColors: [
    Colors.blue.shade400,
    Colors.purple.shade400,
  ],
  gradientBegin: Alignment.topLeft,
  gradientEnd: Alignment.bottomRight,
)
```

#### Button Styling

```dart
OnboardingConfig(
  pages: pages,

  // Style for Next/Done button
  buttonStyle: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 4,
  ),

  // Style for Skip button (optional, different from Next)
  skipButtonStyle: TextButton.styleFrom(
    foregroundColor: Colors.grey,
  ),
)
```

#### Page Indicator Styling

```dart
OnboardingConfig(
  pages: pages,
  indicatorStyle: PageIndicatorStyle(
    activeColor: Colors.blue,
    inactiveColor: Colors.grey.shade300,
    activeSize: 12,
    inactiveSize: 8,
    spacing: 8,
    shape: IndicatorShape.circle, // or .rectangle, .line
  ),
)
```

### Behavior Configuration

```dart
OnboardingConfig(
  pages: pages,

  // Show/hide elements
  showSkipButton: true,      // Show skip button
  showPageIndicator: true,   // Show dot indicators
  showNextButton: true,      // Show next/done button
  showProgress: false,       // Show "1/3", "2/3" text

  // Navigation
  allowPageSwipe: true,      // Allow swiping between pages

  // Auto-advance
  autoAdvance: false,        // Auto go to next page
  autoAdvanceDuration: Duration(seconds: 4),

  // Animation
  transitionDuration: Duration(milliseconds: 300),
  transitionCurve: Curves.easeInOut,

  // Feedback
  enableHapticFeedback: true, // Vibrate on interactions
)
```

### Using Pre-built Templates

#### Feature Showcase

```dart
final config = OnboardingTemplates.createFeatureShowcase(
  features: [
    FeatureItem(
      id: 'feature1',
      title: 'Easy to Use',
      description: 'Intuitive interface anyone can use',
      icon: Icons.touch_app,
    ),
    FeatureItem(
      id: 'feature2',
      title: 'Fast & Reliable',
      description: 'Lightning fast performance',
      icon: Icons.speed,
    ),
  ],
  onComplete: () => navigateToHome(),
  primaryColor: Colors.blue,
);
```

#### Use Common Features

```dart
// For messaging apps
OnboardingTemplates.createFeatureShowcase(
  features: CommonFeatures.messaging,
  onComplete: () => navigateToHome(),
);

// For e-commerce apps
OnboardingTemplates.createFeatureShowcase(
  features: CommonFeatures.ecommerce,
  onComplete: () => navigateToHome(),
);

// For fitness apps
OnboardingTemplates.createFeatureShowcase(
  features: CommonFeatures.fitness,
  onComplete: () => navigateToHome(),
);
```

---

## Troubleshooting

### Issue: Onboarding shows every time I restart the app

**Cause:** Service not initialized or not marking as completed.

**Solution:**

1. Make sure you're passing `onboardingService` to `OnboardingScreen`:

```dart
OnboardingScreen(
  config: config,
  onboardingService: onboardingService, // ← Don't forget this!
)
```

2. The service automatically marks as completed when user finishes, but you can manually test:

```dart
final service = OnboardingService();
await service.initialize();
await service.completeOnboarding();

print(await service.isOnboardingCompleted()); // Should print: true
```

### Issue: Can't import the onboarding module

**Error:** `Target of URI doesn't exist`

**Solution:**

Make sure you're using the correct import path:

```dart
import 'package:reuablewidgets/features/onboarding/onboarding.dart';
```

If that doesn't work, check your project structure. The path should be:
```
your_project/
  lib/
    features/
      onboarding/
        onboarding.dart
```

### Issue: SharedPreferences error on initialization

**Error:** `Unhandled Exception: MissingPluginException`

**Solution:**

Run these commands:

```bash
flutter clean
flutter pub get
flutter run
```

For iOS specifically:
```bash
cd ios
pod install
cd ..
flutter run
```

### Issue: Pages not swiping

**Cause:** `allowPageSwipe` is set to `false`

**Solution:**

```dart
OnboardingConfig(
  pages: pages,
  allowPageSwipe: true, // ← Make sure this is true
)
```

### Issue: Skip button not showing

**Cause:** Either disabled or on last page

**Solution:**

```dart
OnboardingConfig(
  pages: pages,
  showSkipButton: true, // ← Make sure this is true
)
```

Note: Skip button automatically hides on the last page.

### Issue: Images not loading

**Error:** `Unable to load asset`

**Solution:**

1. Check `pubspec.yaml` has assets defined:

```yaml
flutter:
  assets:
    - assets/images/
```

2. Make sure image files exist in that folder
3. Run `flutter pub get`
4. Run `flutter clean` then `flutter run`

### Issue: Text overflowing on small screens

**Solution:**

Reduce font sizes or padding:

```dart
OnboardingConfig(
  pages: pages,
  titleTextStyle: TextStyle(
    fontSize: 24, // Reduced from 28
  ),
  descriptionTextStyle: TextStyle(
    fontSize: 14, // Reduced from 16
  ),
  contentPadding: EdgeInsets.symmetric(
    horizontal: 24, // Reduced from 32
    vertical: 32,   // Reduced from 48
  ),
)
```

### Issue: Version tracking not working

**Solution:**

Make sure you're providing the same version string:

```dart
// Bad - different version each time
final service = OnboardingService(version: DateTime.now().toString());

// Good - consistent version
final service = OnboardingService(version: '1.0.0');
```

---

## Testing

### Test Onboarding Display

```bash
# Run the app
flutter run

# First launch - should show onboarding
# Close and restart - should NOT show onboarding
```

### Reset Onboarding for Testing

Add a button in your app (debug builds only):

```dart
if (kDebugMode) {
  ElevatedButton(
    onPressed: () async {
      final service = OnboardingService();
      await service.initialize();
      await service.resetOnboarding();
      print('Onboarding reset - restart app to see it again');
    },
    child: Text('Reset Onboarding (Debug Only)'),
  );
}
```

### Test Version Changes

```dart
// Start with version 1.0.0
final service = OnboardingService(version: '1.0.0');
await service.initialize();
await service.completeOnboarding();

// Change to version 2.0.0 and restart
final service = OnboardingService(version: '2.0.0');
await service.initialize();
print(await service.shouldShowOnboarding()); // Should be true
```

### Automated Testing

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Onboarding shows on first launch', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    final service = OnboardingService();
    await service.initialize();

    expect(await service.shouldShowOnboarding(), true);

    await service.completeOnboarding();

    expect(await service.shouldShowOnboarding(), false);
  });
}
```

---

## Quick Reference

### Minimal Setup

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final service = OnboardingService();
  await service.initialize();
  runApp(MyApp(showOnboarding: await service.shouldShowOnboarding()));
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;
  const MyApp({required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: showOnboarding
        ? OnboardingScreen(
            config: OnboardingConfig(
              pages: [
                OnboardingPage.withIcon(
                  title: 'Welcome',
                  description: 'Welcome!',
                  icon: Icons.waving_hand,
                ),
              ],
              onComplete: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => HomeScreen()),
              ),
            ),
          )
        : HomeScreen(),
    );
  }
}
```

### Common Imports

```dart
import 'package:flutter/material.dart';
import 'package:reuablewidgets/features/onboarding/onboarding.dart';
```

### Service Methods Quick Reference

```dart
final service = OnboardingService(version: '1.0.0');
await service.initialize();

await service.shouldShowOnboarding();        // Check if should show
await service.completeOnboarding();          // Mark as completed
await service.skipOnboarding();              // Mark as skipped
await service.resetOnboarding();             // Reset for testing
await service.isOnboardingCompleted();       // Check completion status
await service.wasOnboardingSkipped();        // Check if skipped
await service.getLastPageReached();          // Get last page viewed
await service.hasVersionChanged();           // Check version change
```

---

## Next Steps

1. ✅ Follow the Quick Setup above
2. ✅ Customize your pages and styling
3. ✅ Test on different screen sizes
4. ✅ Add analytics tracking (see README.md)
5. ✅ Prepare images/assets if using
6. ✅ Test version tracking
7. ✅ Deploy to production

## Need Help?

- Check [README.md](README.md) for usage examples
- Check [EXAMPLE.md](EXAMPLE.md) for complete code examples
- Review the test file for more examples: `tests/onboarding_service_test.dart`

## License

This module is part of the reusable_widgets project.
