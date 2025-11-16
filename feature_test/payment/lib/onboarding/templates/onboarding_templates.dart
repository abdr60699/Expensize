import 'package:flutter/material.dart';
import '../models/onboarding_page.dart';
import '../models/onboarding_config.dart';

/// Pre-built onboarding templates for common use cases
class OnboardingTemplates {
  /// Create a simple welcome flow with features
  ///
  /// Ideal for showcasing 3-5 key features of your app.
  static OnboardingConfig createFeatureShowcase({
    required List<FeatureItem> features,
    required VoidCallback onComplete,
    VoidCallback? onSkip,
    bool showSkip = true,
    Color? primaryColor,
    List<Color>? gradientColors,
  }) {
    final pages = features.map((feature) {
      return OnboardingPage.withIcon(
        title: feature.title,
        description: feature.description,
        icon: feature.icon,
        iconColor: feature.iconColor ?? primaryColor,
        metadata: {'feature_id': feature.id},
      );
    }).toList();

    return OnboardingConfig(
      pages: pages,
      showSkipButton: showSkip,
      onComplete: onComplete,
      onSkip: onSkip,
      backgroundGradientColors: gradientColors,
    );
  }

  /// Create a permission request flow
  ///
  /// For explaining why permissions are needed before requesting them.
  static OnboardingConfig createPermissionFlow({
    required List<PermissionItem> permissions,
    required VoidCallback onComplete,
    Color? primaryColor,
  }) {
    final pages = permissions.map((permission) {
      return OnboardingPage.withIcon(
        title: permission.title,
        description: permission.description,
        icon: permission.icon,
        iconColor: permission.iconColor ?? primaryColor,
        metadata: {'permission': permission.permission},
      );
    }).toList();

    return OnboardingConfig(
      pages: pages,
      showSkipButton: false, // Don't allow skipping permissions
      onComplete: onComplete,
      doneButtonText: 'Grant Permissions',
    );
  }

  /// Create a tutorial walkthrough flow
  ///
  /// Step-by-step guide for using the app.
  static OnboardingConfig createTutorialWalkthrough({
    required List<TutorialStep> steps,
    required VoidCallback onComplete,
    VoidCallback? onSkip,
  }) {
    final pages = steps.map((step) {
      return OnboardingPage(
        title: step.title,
        description: step.description,
        imagePath: step.imagePath,
        imageWidget: step.imageWidget,
        metadata: {'step_id': step.id, 'step_number': step.stepNumber},
      );
    }).toList();

    return OnboardingConfig(
      pages: pages,
      showProgress: true, // Show "1/5", "2/5", etc.
      showSkipButton: true,
      onComplete: onComplete,
      onSkip: onSkip,
      nextButtonText: 'Continue',
      doneButtonText: 'Start Using App',
    );
  }

  /// Create a minimalist onboarding flow
  ///
  /// Clean, simple design with large text and icons.
  static OnboardingConfig createMinimalist({
    required List<OnboardingPage> pages,
    required VoidCallback onComplete,
    Color? backgroundColor,
    Color? accentColor,
  }) {
    return OnboardingConfig(
      pages: pages,
      showSkipButton: false,
      showPageIndicator: true,
      showNextButton: true,
      onComplete: onComplete,
      titleTextStyle: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: accentColor ?? Colors.black87,
      ),
      descriptionTextStyle: TextStyle(
        fontSize: 18,
        color: (accentColor ?? Colors.black87).withOpacity(0.7),
        height: 1.6,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      indicatorStyle: PageIndicatorStyle(
        activeColor: accentColor,
        activeSize: 10,
        inactiveSize: 8,
        shape: IndicatorShape.circle,
      ),
    );
  }

  /// Create an animated onboarding flow
  ///
  /// With auto-advance and animations between pages.
  static OnboardingConfig createAnimated({
    required List<OnboardingPage> pages,
    required VoidCallback onComplete,
    Duration autoAdvanceDuration = const Duration(seconds: 4),
    List<Color>? gradientColors,
  }) {
    return OnboardingConfig(
      pages: pages,
      showSkipButton: true,
      autoAdvance: true,
      autoAdvanceDuration: autoAdvanceDuration,
      onComplete: onComplete,
      backgroundGradientColors: gradientColors ??
          [
            Colors.purple.shade400,
            Colors.blue.shade400,
            Colors.cyan.shade400,
          ],
      transitionDuration: const Duration(milliseconds: 600),
      transitionCurve: Curves.easeInOutCubic,
    );
  }

  /// Create a value proposition flow
  ///
  /// Highlighting the main benefits/value of the app.
  static OnboardingConfig createValueProposition({
    required List<ValueProposition> propositions,
    required VoidCallback onComplete,
    List<Color>? gradientColors,
  }) {
    final pages = propositions.map((prop) {
      return OnboardingPage.withIcon(
        title: prop.title,
        description: prop.description,
        icon: prop.icon,
        iconColor: prop.color,
        iconSize: 100,
      );
    }).toList();

    return OnboardingConfig(
      pages: pages,
      showSkipButton: true,
      skipButtonText: 'Skip Intro',
      doneButtonText: 'Get Started',
      onComplete: onComplete,
      backgroundGradientColors: gradientColors,
      titleTextStyle: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      descriptionTextStyle: const TextStyle(
        fontSize: 17,
        height: 1.6,
      ),
    );
  }

  /// Create a quick setup flow
  ///
  /// For collecting user preferences or initial setup.
  static OnboardingConfig createQuickSetup({
    required List<OnboardingPage> setupPages,
    required VoidCallback onComplete,
  }) {
    return OnboardingConfig(
      pages: setupPages,
      showSkipButton: false,
      showProgress: true,
      allowPageSwipe: false, // Force users to go through setup in order
      nextButtonText: 'Next',
      doneButtonText: 'Complete Setup',
      onComplete: onComplete,
    );
  }
}

/// Model for a feature to showcase
class FeatureItem {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color? iconColor;

  const FeatureItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.iconColor,
  });
}

/// Model for a permission request
class PermissionItem {
  final String permission;
  final String title;
  final String description;
  final IconData icon;
  final Color? iconColor;

  const PermissionItem({
    required this.permission,
    required this.title,
    required this.description,
    required this.icon,
    this.iconColor,
  });
}

/// Model for a tutorial step
class TutorialStep {
  final String id;
  final int stepNumber;
  final String title;
  final String description;
  final String? imagePath;
  final Widget? imageWidget;

  const TutorialStep({
    required this.id,
    required this.stepNumber,
    required this.title,
    required this.description,
    this.imagePath,
    this.imageWidget,
  });
}

/// Model for a value proposition
class ValueProposition {
  final String title;
  final String description;
  final IconData icon;
  final Color? color;

  const ValueProposition({
    required this.title,
    required this.description,
    required this.icon,
    this.color,
  });
}

/// Example feature items for common app types
class CommonFeatures {
  /// Messaging app features
  static List<FeatureItem> messaging = [
    const FeatureItem(
      id: 'instant_messaging',
      title: 'Instant Messaging',
      description: 'Send messages to friends and family instantly',
      icon: Icons.message,
    ),
    const FeatureItem(
      id: 'voice_calls',
      title: 'Voice & Video Calls',
      description: 'Make high-quality voice and video calls',
      icon: Icons.call,
    ),
    const FeatureItem(
      id: 'group_chat',
      title: 'Group Chats',
      description: 'Create groups and chat with multiple people',
      icon: Icons.group,
    ),
  ];

  /// E-commerce app features
  static List<FeatureItem> ecommerce = [
    const FeatureItem(
      id: 'browse',
      title: 'Browse Products',
      description: 'Explore thousands of products',
      icon: Icons.shopping_bag,
    ),
    const FeatureItem(
      id: 'secure_payment',
      title: 'Secure Payment',
      description: 'Shop safely with encrypted payments',
      icon: Icons.credit_card,
    ),
    const FeatureItem(
      id: 'fast_delivery',
      title: 'Fast Delivery',
      description: 'Get your orders delivered quickly',
      icon: Icons.local_shipping,
    ),
  ];

  /// Fitness app features
  static List<FeatureItem> fitness = [
    const FeatureItem(
      id: 'track_workouts',
      title: 'Track Workouts',
      description: 'Log and monitor your exercise routines',
      icon: Icons.fitness_center,
    ),
    const FeatureItem(
      id: 'monitor_progress',
      title: 'Monitor Progress',
      description: 'See your improvement over time',
      icon: Icons.trending_up,
    ),
    const FeatureItem(
      id: 'set_goals',
      title: 'Set Goals',
      description: 'Define and achieve your fitness goals',
      icon: Icons.flag,
    ),
  ];
}

/// Common permission items
class CommonPermissions {
  static const location = PermissionItem(
    permission: 'location',
    title: 'Location Access',
    description: 'We need your location to provide relevant nearby content and services',
    icon: Icons.location_on,
  );

  static const camera = PermissionItem(
    permission: 'camera',
    title: 'Camera Access',
    description: 'Take photos and videos to share with others',
    icon: Icons.camera_alt,
  );

  static const notifications = PermissionItem(
    permission: 'notifications',
    title: 'Notifications',
    description: 'Stay updated with important alerts and messages',
    icon: Icons.notifications,
  );

  static const storage = PermissionItem(
    permission: 'storage',
    title: 'Storage Access',
    description: 'Save and access your photos and files',
    icon: Icons.folder,
  );

  static const microphone = PermissionItem(
    permission: 'microphone',
    title: 'Microphone Access',
    description: 'Record audio and make voice calls',
    icon: Icons.mic,
  );
}
