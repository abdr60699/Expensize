# Onboarding Module - Complete Example

This example demonstrates a full integration of the onboarding module in a Flutter app.

## Complete App Example

```dart
import 'package:flutter/material.dart';
import 'package:reuablewidgets/features/onboarding/onboarding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize onboarding service
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
      title: 'Onboarding Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashScreen(onboardingService: onboardingService),
    );
  }
}

/// Splash screen that decides whether to show onboarding
class SplashScreen extends StatefulWidget {
  final OnboardingService onboardingService;

  const SplashScreen({required this.onboardingService});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    // Simulate loading time
    await Future.delayed(Duration(seconds: 1));

    final shouldShow = await widget.onboardingService.shouldShowOnboarding();

    if (mounted) {
      if (shouldShow) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OnboardingFlow(
              onboardingService: widget.onboardingService,
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

/// Onboarding flow widget
class OnboardingFlow extends StatefulWidget {
  final OnboardingService onboardingService;

  const OnboardingFlow({required this.onboardingService});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  late OnboardingAnalytics analytics;
  late DateTime startTime;

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();

    // Initialize analytics
    analytics = OnboardingAnalytics(
      onLogEvent: (name, params) {
        print('Analytics Event: $name');
        print('Parameters: $params');
        // In production, send to your analytics provider
      },
    );

    // Track onboarding start
    analytics.trackOnboardingStarted();
  }

  void _handleComplete() {
    // Track completion
    final timeSpent = DateTime.now().difference(startTime);
    analytics.trackOnboardingCompleted(
      totalPages: 5,
      timeSpent: timeSpent,
    );

    // Navigate to home
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen()),
    );
  }

  void _handleSkip() {
    // Track skip
    analytics.trackOnboardingSkipped(
      pageReached: 0,
      totalPages: 5,
    );

    // Navigate to home
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen()),
    );
  }

  void _handlePageChanged(int index) {
    // Track page view
    final pages = _getPages();
    analytics.trackPageViewed(index, pages[index].title);
  }

  List<OnboardingPage> _getPages() {
    return [
      OnboardingPage.withIcon(
        title: 'Welcome!',
        description: 'Thank you for choosing our app. Let\'s get you started.',
        icon: Icons.waving_hand,
        iconColor: Colors.amber,
        backgroundColor: Colors.blue.shade50,
      ),
      OnboardingPage.withIcon(
        title: 'Stay Connected',
        description: 'Chat with friends and family instantly, anytime, anywhere.',
        icon: Icons.chat_bubble_outline,
        iconColor: Colors.blue,
        backgroundColor: Colors.purple.shade50,
      ),
      OnboardingPage.withIcon(
        title: 'Share Moments',
        description: 'Share photos, videos, and memories with the people you care about.',
        icon: Icons.photo_camera,
        iconColor: Colors.purple,
        backgroundColor: Colors.pink.shade50,
      ),
      OnboardingPage.withIcon(
        title: 'Stay Secure',
        description: 'Your privacy is important. All your data is encrypted end-to-end.',
        icon: Icons.security,
        iconColor: Colors.green,
        backgroundColor: Colors.green.shade50,
      ),
      OnboardingPage.withIcon(
        title: 'Get Started',
        description: 'You\'re all set! Let\'s begin your journey with us.',
        icon: Icons.rocket_launch,
        iconColor: Colors.orange,
        backgroundColor: Colors.orange.shade50,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final config = OnboardingConfig(
      pages: _getPages(),
      onComplete: _handleComplete,
      onSkip: _handleSkip,
      onPageChanged: _handlePageChanged,
      showSkipButton: true,
      showPageIndicator: true,
      showNextButton: true,
      skipButtonText: 'Skip',
      nextButtonText: 'Next',
      doneButtonText: 'Get Started',
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
      indicatorStyle: PageIndicatorStyle(
        activeColor: Colors.deepPurple,
        inactiveColor: Colors.grey.shade300,
        activeSize: 10,
        inactiveSize: 8,
      ),
      buttonStyle: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
    );

    return OnboardingScreen(
      config: config,
      onboardingService: widget.onboardingService,
    );
  }
}

/// Home screen shown after onboarding
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => _showOnboardingAgain(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 100,
              color: Colors.green,
            ),
            SizedBox(height: 24),
            Text(
              'Welcome to the app!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 16),
            Text(
              'You have completed onboarding',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showOnboardingAgain(context),
              icon: Icon(Icons.replay),
              label: Text('View Onboarding Again'),
            ),
          ],
        ),
      ),
    );
  }

  void _showOnboardingAgain(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OnboardingFlow(
          onboardingService: OnboardingService(),
        ),
      ),
    );
  }
}
```

## Example with Templates

```dart
import 'package:flutter/material.dart';
import 'package:reuablewidgets/features/onboarding/onboarding.dart';

class TemplateExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: OnboardingScreen(
        config: OnboardingTemplates.createFeatureShowcase(
          features: CommonFeatures.messaging,
          onComplete: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen()),
            );
          },
          showSkip: true,
          primaryColor: Colors.blue,
          gradientColors: [
            Colors.blue.shade300,
            Colors.purple.shade300,
          ],
        ),
      ),
    );
  }
}
```

## Example with Permissions

```dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:reuablewidgets/features/onboarding/onboarding.dart';

class PermissionOnboardingExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: OnboardingScreen(
        config: OnboardingTemplates.createPermissionFlow(
          permissions: [
            CommonPermissions.camera,
            CommonPermissions.microphone,
            CommonPermissions.notifications,
          ],
          onComplete: () async {
            // Request actual permissions
            await _requestPermissions();

            // Navigate to home
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen()),
            );
          },
        ),
      ),
    );
  }

  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.microphone.request();
    await Permission.notification.request();
  }
}
```

## Example with Custom Design

```dart
import 'package:flutter/material.dart';
import 'package:reuablewidgets/features/onboarding/onboarding.dart';

class CustomDesignExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final pages = [
      OnboardingPage(
        title: 'Beautiful Design',
        description: 'Custom styled onboarding',
        icon: Icons.palette,
        iconColor: Colors.white,
        backgroundColor: Colors.transparent,
      ),
      OnboardingPage(
        title: 'Amazing Features',
        description: 'Everything you need',
        icon: Icons.star,
        iconColor: Colors.white,
        backgroundColor: Colors.transparent,
      ),
    ];

    final config = OnboardingConfig(
      pages: pages,
      backgroundGradientColors: [
        Color(0xFF667eea),
        Color(0xFF764ba2),
      ],
      gradientBegin: Alignment.topLeft,
      gradientEnd: Alignment.bottomRight,
      titleTextStyle: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: -0.5,
      ),
      descriptionTextStyle: TextStyle(
        fontSize: 18,
        color: Colors.white.withOpacity(0.9),
        height: 1.6,
      ),
      indicatorStyle: PageIndicatorStyle(
        activeColor: Colors.white,
        inactiveColor: Colors.white.withOpacity(0.3),
        activeSize: 12,
        inactiveSize: 8,
        shape: IndicatorShape.line,
      ),
      buttonStyle: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF667eea),
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 8,
        shadowColor: Colors.black26,
      ),
      skipButtonStyle: TextButton.styleFrom(
        foregroundColor: Colors.white,
      ),
      onComplete: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      },
    );

    return MaterialApp(
      home: OnboardingScreen(config: config),
    );
  }
}
```

## Example with Auto-Advance

```dart
import 'package:flutter/material.dart';
import 'package:reuablewidgets/features/onboarding/onboarding.dart';

class AutoAdvanceExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final config = OnboardingTemplates.createAnimated(
      pages: [
        OnboardingPage.withIcon(
          title: 'Slide 1',
          description: 'This will auto-advance',
          icon: Icons.looks_one,
        ),
        OnboardingPage.withIcon(
          title: 'Slide 2',
          description: 'After 4 seconds',
          icon: Icons.looks_two,
        ),
        OnboardingPage.withIcon(
          title: 'Slide 3',
          description: 'Or swipe manually',
          icon: Icons.looks_3,
        ),
      ],
      onComplete: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      },
      autoAdvanceDuration: Duration(seconds: 4),
    );

    return MaterialApp(
      home: OnboardingScreen(config: config),
    );
  }
}
```

## Testing the Onboarding

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:reuablewidgets/features/onboarding/onboarding.dart';

void main() {
  testWidgets('Onboarding displays all pages', (tester) async {
    final pages = [
      OnboardingPage.withIcon(
        title: 'Page 1',
        description: 'Description 1',
        icon: Icons.home,
      ),
      OnboardingPage.withIcon(
        title: 'Page 2',
        description: 'Description 2',
        icon: Icons.star,
      ),
    ];

    final config = OnboardingConfig(
      pages: pages,
      onComplete: () {},
    );

    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingScreen(config: config),
      ),
    );

    // Verify first page is displayed
    expect(find.text('Page 1'), findsOneWidget);
    expect(find.text('Description 1'), findsOneWidget);

    // Swipe to next page
    await tester.drag(
      find.byType(PageView),
      Offset(-400, 0),
    );
    await tester.pumpAndSettle();

    // Verify second page is displayed
    expect(find.text('Page 2'), findsOneWidget);
    expect(find.text('Description 2'), findsOneWidget);
  });
}
```

## Tips for Production

1. **Track Analytics**: Monitor where users drop off to optimize the flow
2. **A/B Test**: Try different messaging and see what works better
3. **Keep It Fresh**: Update onboarding when adding major features
4. **Test Thoroughly**: Test on various screen sizes and orientations
5. **Allow Replay**: Let users view onboarding again from settings
6. **Be Concise**: Keep text short and benefits clear
7. **Use Animation**: Consider adding Lottie animations for better engagement
8. **Version Control**: Use version tracking to show updated onboarding
