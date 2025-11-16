/// Onboarding Module
///
/// Production-ready onboarding module for Flutter apps.
///
/// Provides intro sliders, app walkthroughs, customizable templates,
/// persistent completion tracking, and analytics integration.
///
/// ## Quick Start
///
/// ```dart
/// import 'package:reuablewidgets/features/onboarding/onboarding.dart';
///
/// // Create pages
/// final pages = [
///   OnboardingPage.withIcon(
///     title: 'Welcome',
///     description: 'Welcome to our app!',
///     icon: Icons.waving_hand,
///   ),
/// ];
///
/// // Create configuration
/// final config = OnboardingConfig(
///   pages: pages,
///   onComplete: () => navigateToHome(),
/// );
///
/// // Show onboarding
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (_) => OnboardingScreen(config: config),
///   ),
/// );
/// ```
///
/// ## With Persistence
///
/// ```dart
/// final service = OnboardingService(version: '1.0.0');
/// await service.initialize();
///
/// if (await service.shouldShowOnboarding()) {
///   // Show onboarding
/// } else {
///   // Go to home
/// }
/// ```
///
/// For detailed documentation, see README.md and EXAMPLE.md.
library onboarding;

// Models
export 'models/onboarding_page.dart';
export 'models/onboarding_config.dart';

// Services
export 'services/onboarding_service.dart';
export 'services/onboarding_analytics.dart';

// Widgets
export 'widgets/onboarding_screen.dart';
export 'widgets/onboarding_page_widget.dart';
export 'widgets/page_indicator.dart';

// Templates
export 'templates/onboarding_templates.dart';
