# Onboarding Module

Production-ready, reusable onboarding module for Flutter apps. Provides intro sliders, app walkthroughs, customizable templates, and persistent completion tracking.

## 📋 Integration Checklist

Follow these steps to add onboarding to your Flutter app (5 minutes):

- [ ] **Step 1:** Import the module: `import 'package:reuablewidgets/features/onboarding/onboarding.dart';`
- [ ] **Step 2:** Initialize service in `main.dart`: `final service = OnboardingService(); await service.initialize();`
- [ ] **Step 3:** Check if should show: `await service.shouldShowOnboarding()`
- [ ] **Step 4:** Create your pages with `OnboardingPage.withIcon()` or templates
- [ ] **Step 5:** Show `OnboardingScreen` with config and service
- [ ] **Step 6:** Navigate to home on `onComplete` callback
- [ ] **Step 7:** Test by running your app (should show once, then never again)

**Need detailed instructions?** See [SETUP_GUIDE.md](SETUP_GUIDE.md) for step-by-step integration guide.

**Need code examples?** See [EXAMPLE.md](EXAMPLE.md) for complete working examples.

## Features

- **Intro Slider** - Multi-screen onboarding with swipe navigation
- **Pre-built Templates** - Feature showcase, permissions, tutorials, and more
- **First-Time User Logic** - Automatic detection and tracking
- **Skip/Next/Done Flows** - Customizable navigation controls
- **Persistence** - Tracks completion state with SharedPreferences
- **Version Tracking** - Show onboarding again when updated
- **Analytics Integration** - Track user progress through onboarding
- **Theming Support** - Fully customizable appearance
- **Page Indicators** - Dots, progress, or custom indicators
- **Auto-Advance** - Optional automatic page progression
- **Haptic Feedback** - Tactile response for interactions
- **Production-Ready** - Comprehensive error handling and testing

## Quick Start

### 1. Basic Usage

```dart
import 'package:reuablewidgets/features/onboarding/onboarding.dart';

// Define your onboarding pages
final pages = [
  OnboardingPage.withIcon(
    title: 'Welcome',
    description: 'Welcome to our amazing app!',
    icon: Icons.waving_hand,
    iconColor: Colors.blue,
  ),
  OnboardingPage.withIcon(
    title: 'Explore Features',
    description: 'Discover all the great features we offer',
    icon: Icons.explore,
    iconColor: Colors.green,
  ),
  OnboardingPage.withIcon(
    title: 'Get Started',
    description: 'Let\'s begin your journey!',
    icon: Icons.rocket_launch,
    iconColor: Colors.orange,
  ),
];

// Create configuration
final config = OnboardingConfig(
  pages: pages,
  onComplete: () {
    // Navigate to home screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen()),
    );
  },
  onSkip: () {
    // Handle skip
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen()),
    );
  },
);

// Show onboarding
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => OnboardingScreen(config: config),
  ),
);
```

### 2. With Persistence

```dart
// Initialize service
final onboardingService = OnboardingService(version: '1.0.0');
await onboardingService.initialize();

// Check if onboarding should be shown
if (await onboardingService.shouldShowOnboarding()) {
  // Show onboarding
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => OnboardingScreen(
        config: config,
        onboardingService: onboardingService,
      ),
    ),
  );
} else {
  // User has completed onboarding - go to home
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => HomeScreen()),
  );
}
```

### 3. In main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final onboardingService = OnboardingService(version: '1.0.0');
  await onboardingService.initialize();

  final shouldShowOnboarding = await onboardingService.shouldShowOnboarding();

  runApp(MyApp(shouldShowOnboarding: shouldShowOnboarding));
}

class MyApp extends StatelessWidget {
  final bool shouldShowOnboarding;

  const MyApp({required this.shouldShowOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: shouldShowOnboarding ? OnboardingFlow() : HomeScreen(),
    );
  }
}
```

## Creating Pages

### With Icons

```dart
OnboardingPage.withIcon(
  title: 'Fast & Secure',
  description: 'Your data is encrypted and protected',
  icon: Icons.security,
  iconColor: Colors.blue,
  iconSize: 120,
)
```

### With Images

```dart
OnboardingPage.withImage(
  title: 'Beautiful UI',
  description: 'Enjoy our modern and intuitive design',
  imagePath: 'assets/images/onboarding1.png',
)
```

### With Custom Widget

```dart
OnboardingPage.custom(
  widget: MyCustomOnboardingWidget(),
  title: 'Custom Page',  // Optional, for analytics
  description: 'Custom description',
)
```

### With Background Color

```dart
OnboardingPage.withIcon(
  title: 'Colorful',
  description: 'Each page can have its own background',
  icon: Icons.palette,
  backgroundColor: Colors.purple.shade100,
  textColor: Colors.white,
)
```

## Configuration Options

### Basic Configuration

```dart
OnboardingConfig(
  pages: pages,
  showSkipButton: true,  // Show skip button
  showPageIndicator: true,  // Show dot indicators
  showNextButton: true,  // Show next/done button
  showProgress: false,  // Show "1/3", "2/3", etc.
  skipButtonText: 'Skip',
  nextButtonText: 'Next',
  doneButtonText: 'Done',
  allowPageSwipe: true,  // Allow swiping between pages
)
```

### Styling

```dart
OnboardingConfig(
  pages: pages,
  // Background gradient
  backgroundGradientColors: [
    Colors.blue.shade400,
    Colors.purple.shade400,
  ],
  gradientBegin: Alignment.topLeft,
  gradientEnd: Alignment.bottomRight,

  // Text styles
  titleTextStyle: TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  ),
  descriptionTextStyle: TextStyle(
    fontSize: 18,
    color: Colors.white70,
  ),

  // Layout
  contentPadding: EdgeInsets.symmetric(horizontal: 32, vertical: 48),
  imageHeightRatio: 0.4,  // 40% of screen height
  imageTextSpacing: 40,

  // Indicator style
  indicatorStyle: PageIndicatorStyle(
    activeColor: Colors.white,
    inactiveColor: Colors.white38,
    activeSize: 12,
    inactiveSize: 8,
    shape: IndicatorShape.circle,
  ),

  // Button style
  buttonStyle: ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: Colors.blue,
    padding: EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
)
```

### Auto-Advance

```dart
OnboardingConfig(
  pages: pages,
  autoAdvance: true,
  autoAdvanceDuration: Duration(seconds: 4),
  transitionDuration: Duration(milliseconds: 500),
  transitionCurve: Curves.easeInOutCubic,
)
```

### Callbacks

```dart
OnboardingConfig(
  pages: pages,
  onComplete: () {
    print('Onboarding completed');
    // Navigate away
  },
  onSkip: () {
    print('Onboarding skipped');
    // Navigate away
  },
  onPageChanged: (index) {
    print('Now on page $index');
    // Track analytics
  },
)
```

## Using Templates

The module includes pre-built templates for common use cases:

### Feature Showcase

```dart
final config = OnboardingTemplates.createFeatureShowcase(
  features: [
    FeatureItem(
      id: 'messaging',
      title: 'Instant Messaging',
      description: 'Chat with friends in real-time',
      icon: Icons.message,
    ),
    FeatureItem(
      id: 'calls',
      title: 'Voice & Video Calls',
      description: 'High-quality calls anywhere',
      icon: Icons.call,
    ),
  ],
  onComplete: () => navigateToHome(),
  primaryColor: Colors.blue,
);
```

### Permission Flow

```dart
final config = OnboardingTemplates.createPermissionFlow(
  permissions: [
    CommonPermissions.camera,
    CommonPermissions.notifications,
    CommonPermissions.location,
  ],
  onComplete: () async {
    // Request actual permissions
    await requestPermissions();
  },
);
```

### Tutorial Walkthrough

```dart
final config = OnboardingTemplates.createTutorialWalkthrough(
  steps: [
    TutorialStep(
      id: 'step1',
      stepNumber: 1,
      title: 'Create Account',
      description: 'Tap the sign up button to get started',
      imagePath: 'assets/tutorial/step1.png',
    ),
    // More steps...
  ],
  onComplete: () => navigateToHome(),
  onSkip: () => navigateToHome(),
);
```

### Value Proposition

```dart
final config = OnboardingTemplates.createValueProposition(
  propositions: [
    ValueProposition(
      title: 'Save Time',
      description: 'Get things done 10x faster',
      icon: Icons.access_time,
      color: Colors.green,
    ),
    ValueProposition(
      title: 'Stay Organized',
      description: 'Keep everything in one place',
      icon: Icons.folder_special,
      color: Colors.orange,
    ),
  ],
  onComplete: () => navigateToHome(),
  gradientColors: [Colors.purple, Colors.blue],
);
```

### Pre-defined Features

Use common feature sets:

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

## Persistence Management

### OnboardingService

```dart
final service = OnboardingService(version: '1.0.0');
await service.initialize();

// Check status
final completed = await service.isOnboardingCompleted();
final shouldShow = await service.shouldShowOnboarding();

// Mark completed
await service.completeOnboarding(pageReached: 3);

// Mark skipped
await service.skipOnboarding(pageReached: 1);

// Check if skipped
final wasSkipped = await service.wasOnboardingSkipped();

// Get metadata
final completedAt = await service.getCompletedAt();
final lastPage = await service.getLastPageReached();
final version = await service.getCompletedVersion();

// Reset (for testing or allowing replay)
await service.resetOnboarding();

// Update progress
await service.updateLastPage(2);

// Export data
final data = await service.getOnboardingData();
```

### Version Tracking

```dart
// Version 1.0.0
final service = OnboardingService(version: '1.0.0');
await service.initialize();
await service.completeOnboarding();

// Later, version 2.0.0
final newService = OnboardingService(version: '2.0.0');
await newService.initialize();

// Will return true - user needs to see new onboarding
final shouldShow = await newService.shouldShowOnboarding();

// Check if version changed
final changed = await newService.hasVersionChanged();  // true
```

## Analytics Integration

### Basic Analytics

```dart
final analytics = OnboardingAnalytics(
  onLogEvent: (name, params) {
    print('Event: $name, Params: $params');
    // Send to your analytics provider
  },
);

// Track events
analytics.trackOnboardingStarted();
analytics.trackPageViewed(0, 'Welcome');
analytics.trackNextButtonClicked(0);
analytics.trackOnboardingCompleted(
  totalPages: 3,
  timeSpent: Duration(minutes: 2),
);
analytics.trackOnboardingSkipped(
  pageReached: 1,
  totalPages: 3,
);
```

### With Analytics Module

If you're using the analytics_logging module:

```dart
import 'package:reuablewidgets/features/analytics_logging/analytics_logging.dart';
import 'package:reuablewidgets/features/onboarding/onboarding.dart';

final analytics = OnboardingAnalytics(
  onLogEvent: (name, params) {
    analyticsManager.logEvent(
      AnalyticsEvent.custom(name: name, parameters: params),
    );
  },
);

// Now onboarding events will be tracked in your analytics
```

## Advanced Customization

### Custom Page Layout

```dart
OnboardingPage.custom(
  widget: Container(
    padding: EdgeInsets.all(40),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset('assets/animations/welcome.json'),
        SizedBox(height: 40),
        Text('Custom Layout', style: TextStyle(fontSize: 28)),
        // Any custom widgets
      ],
    ),
  ),
)
```

### Custom Page Indicator

```dart
OnboardingConfig(
  pages: pages,
  showPageIndicator: false,  // Hide default
  // Add your own indicator in a custom widget
)
```

### Disable Swiping

```dart
OnboardingConfig(
  pages: pages,
  allowPageSwipe: false,  // Users must use Next button
)
```

### Minimal Design

```dart
final config = OnboardingTemplates.createMinimalist(
  pages: pages,
  onComplete: () => navigateToHome(),
  backgroundColor: Colors.white,
  accentColor: Colors.black,
);
```

## Page Indicator Styles

### Circle (Default)

```dart
indicatorStyle: PageIndicatorStyle(
  shape: IndicatorShape.circle,
  activeSize: 12,
  inactiveSize: 8,
)
```

### Rectangle

```dart
indicatorStyle: PageIndicatorStyle(
  shape: IndicatorShape.rectangle,
  activeSize: 10,
  inactiveSize: 8,
)
```

### Line

```dart
indicatorStyle: PageIndicatorStyle(
  shape: IndicatorShape.line,
  activeSize: 8,
  inactiveSize: 6,
)
```

## Best Practices

### 1. Keep It Short

Limit onboarding to 3-5 screens maximum. Users want to start using your app quickly.

### 2. Focus on Value

Show the benefits and value of your app, not just features. Answer "What's in it for me?"

### 3. Allow Skipping

Always provide a skip option. Some users prefer to explore on their own.

### 4. Use Version Tracking

Use version tracking to show updated onboarding when you add major features.

### 5. Track Analytics

Monitor completion rates and where users drop off to optimize your onboarding.

### 6. Test on Different Screen Sizes

Ensure your content looks good on various devices and orientations.

### 7. Make It Interactive

Consider adding interactive elements or animations to engage users.

### 8. Explain Permissions

If requesting permissions, clearly explain why each permission is needed.

## Complete Example

See [EXAMPLE.md](EXAMPLE.md) for a complete working example with:
- Main app integration
- Permission handling
- Analytics tracking
- Custom theming
- Navigation flow

## Testing

Run tests for the module:

```bash
flutter test lib/features/onboarding/tests/
```

## Dependencies

The module uses:
- `shared_preferences` - For persistence (already in project)
- Standard Flutter widgets

No additional dependencies required!

## License

This module is part of the reusable_widgets project.

## 📚 Documentation

- **[SETUP_GUIDE.md](SETUP_GUIDE.md)** - Complete step-by-step integration guide
- **[EXAMPLE.md](EXAMPLE.md)** - Full code examples and patterns
- **[README.md](README.md)** - This file - usage and API reference

## 🐛 Troubleshooting

**Onboarding shows every time?**
- Make sure you're passing `onboardingService` to `OnboardingScreen`
- Check that service is initialized before use

**Can't import the module?**
- Verify path: `import 'package:reuablewidgets/features/onboarding/onboarding.dart';`

**Images not loading?**
- Add assets to `pubspec.yaml`: `assets: - assets/images/`
- Run `flutter pub get`

**More issues?** See the [Troubleshooting section in SETUP_GUIDE.md](SETUP_GUIDE.md#troubleshooting)

## 🎯 Quick Links

| What you need | Where to find it |
|--------------|------------------|
| **First time setup** | [SETUP_GUIDE.md](SETUP_GUIDE.md) |
| **Code examples** | [EXAMPLE.md](EXAMPLE.md) |
| **Templates** | [OnboardingTemplates section](#using-templates) |
| **Customization** | [Configuration Options](#configuration-options) |
| **Testing** | [SETUP_GUIDE.md - Testing](SETUP_GUIDE.md#testing) |
| **Troubleshooting** | [SETUP_GUIDE.md - Troubleshooting](SETUP_GUIDE.md#troubleshooting) |

## License

This module is part of the reusable_widgets project.
