import 'package:flutter/material.dart';
import 'onboarding_page.dart';

/// Configuration for the onboarding flow
///
/// Defines behavior, styling, and callbacks for the onboarding experience.
class OnboardingConfig {
  /// List of pages to display in the onboarding flow
  final List<OnboardingPage> pages;

  /// Whether to show the "Skip" button
  final bool showSkipButton;

  /// Whether to show the page indicator (dots)
  final bool showPageIndicator;

  /// Whether to show the "Next" button
  final bool showNextButton;

  /// Whether to show progress (e.g., "1/3")
  final bool showProgress;

  /// Text for the skip button
  final String skipButtonText;

  /// Text for the next button
  final String nextButtonText;

  /// Text for the done/finish button (shown on last page)
  final String doneButtonText;

  /// Whether users can swipe between pages
  final bool allowPageSwipe;

  /// Whether to auto-advance pages after a delay
  final bool autoAdvance;

  /// Duration before auto-advancing (if autoAdvance is true)
  final Duration autoAdvanceDuration;

  /// Animation curve for page transitions
  final Curve transitionCurve;

  /// Duration of page transition animations
  final Duration transitionDuration;

  /// Callback when user completes onboarding
  final VoidCallback? onComplete;

  /// Callback when user skips onboarding
  final VoidCallback? onSkip;

  /// Callback when page changes
  final void Function(int index)? onPageChanged;

  /// Whether to track analytics events
  final bool enableAnalytics;

  /// Custom background gradient colors
  final List<Color>? backgroundGradientColors;

  /// Alignment for background gradient
  final AlignmentGeometry? gradientBegin;
  final AlignmentGeometry? gradientEnd;

  /// Default text style for titles
  final TextStyle? titleTextStyle;

  /// Default text style for descriptions
  final TextStyle? descriptionTextStyle;

  /// Padding around content
  final EdgeInsets? contentPadding;

  /// Height ratio for images (0.0 to 1.0)
  final double imageHeightRatio;

  /// Spacing between image and text
  final double imageTextSpacing;

  /// Page indicator style
  final PageIndicatorStyle indicatorStyle;

  /// Button style
  final ButtonStyle? buttonStyle;

  /// Skip button style (overrides buttonStyle for skip button)
  final ButtonStyle? skipButtonStyle;

  /// Whether to vibrate on page change (haptic feedback)
  final bool enableHapticFeedback;

  const OnboardingConfig({
    required this.pages,
    this.showSkipButton = true,
    this.showPageIndicator = true,
    this.showNextButton = true,
    this.showProgress = false,
    this.skipButtonText = 'Skip',
    this.nextButtonText = 'Next',
    this.doneButtonText = 'Done',
    this.allowPageSwipe = true,
    this.autoAdvance = false,
    this.autoAdvanceDuration = const Duration(seconds: 3),
    this.transitionCurve = Curves.easeInOut,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.onComplete,
    this.onSkip,
    this.onPageChanged,
    this.enableAnalytics = true,
    this.backgroundGradientColors,
    this.gradientBegin,
    this.gradientEnd,
    this.titleTextStyle,
    this.descriptionTextStyle,
    this.contentPadding,
    this.imageHeightRatio = 0.4,
    this.imageTextSpacing = 32.0,
    this.indicatorStyle = const PageIndicatorStyle(),
    this.buttonStyle,
    this.skipButtonStyle,
    this.enableHapticFeedback = true,
  }) : assert(pages.length > 0, 'Must provide at least one page');

  /// Create a copy with modified fields
  OnboardingConfig copyWith({
    List<OnboardingPage>? pages,
    bool? showSkipButton,
    bool? showPageIndicator,
    bool? showNextButton,
    bool? showProgress,
    String? skipButtonText,
    String? nextButtonText,
    String? doneButtonText,
    bool? allowPageSwipe,
    bool? autoAdvance,
    Duration? autoAdvanceDuration,
    Curve? transitionCurve,
    Duration? transitionDuration,
    VoidCallback? onComplete,
    VoidCallback? onSkip,
    void Function(int)? onPageChanged,
    bool? enableAnalytics,
    List<Color>? backgroundGradientColors,
    AlignmentGeometry? gradientBegin,
    AlignmentGeometry? gradientEnd,
    TextStyle? titleTextStyle,
    TextStyle? descriptionTextStyle,
    EdgeInsets? contentPadding,
    double? imageHeightRatio,
    double? imageTextSpacing,
    PageIndicatorStyle? indicatorStyle,
    ButtonStyle? buttonStyle,
    ButtonStyle? skipButtonStyle,
    bool? enableHapticFeedback,
  }) {
    return OnboardingConfig(
      pages: pages ?? this.pages,
      showSkipButton: showSkipButton ?? this.showSkipButton,
      showPageIndicator: showPageIndicator ?? this.showPageIndicator,
      showNextButton: showNextButton ?? this.showNextButton,
      showProgress: showProgress ?? this.showProgress,
      skipButtonText: skipButtonText ?? this.skipButtonText,
      nextButtonText: nextButtonText ?? this.nextButtonText,
      doneButtonText: doneButtonText ?? this.doneButtonText,
      allowPageSwipe: allowPageSwipe ?? this.allowPageSwipe,
      autoAdvance: autoAdvance ?? this.autoAdvance,
      autoAdvanceDuration: autoAdvanceDuration ?? this.autoAdvanceDuration,
      transitionCurve: transitionCurve ?? this.transitionCurve,
      transitionDuration: transitionDuration ?? this.transitionDuration,
      onComplete: onComplete ?? this.onComplete,
      onSkip: onSkip ?? this.onSkip,
      onPageChanged: onPageChanged ?? this.onPageChanged,
      enableAnalytics: enableAnalytics ?? this.enableAnalytics,
      backgroundGradientColors:
          backgroundGradientColors ?? this.backgroundGradientColors,
      gradientBegin: gradientBegin ?? this.gradientBegin,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      titleTextStyle: titleTextStyle ?? this.titleTextStyle,
      descriptionTextStyle: descriptionTextStyle ?? this.descriptionTextStyle,
      contentPadding: contentPadding ?? this.contentPadding,
      imageHeightRatio: imageHeightRatio ?? this.imageHeightRatio,
      imageTextSpacing: imageTextSpacing ?? this.imageTextSpacing,
      indicatorStyle: indicatorStyle ?? this.indicatorStyle,
      buttonStyle: buttonStyle ?? this.buttonStyle,
      skipButtonStyle: skipButtonStyle ?? this.skipButtonStyle,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
    );
  }

  @override
  String toString() {
    return 'OnboardingConfig(pages: ${pages.length}, showSkip: $showSkipButton, showIndicator: $showPageIndicator)';
  }
}

/// Style configuration for the page indicator
class PageIndicatorStyle {
  /// Active dot color
  final Color? activeColor;

  /// Inactive dot color
  final Color? inactiveColor;

  /// Active dot size
  final double activeSize;

  /// Inactive dot size
  final double inactiveSize;

  /// Spacing between dots
  final double spacing;

  /// Dot shape
  final IndicatorShape shape;

  /// Animation duration for indicator changes
  final Duration animationDuration;

  /// Animation curve
  final Curve animationCurve;

  const PageIndicatorStyle({
    this.activeColor,
    this.inactiveColor,
    this.activeSize = 12.0,
    this.inactiveSize = 8.0,
    this.spacing = 8.0,
    this.shape = IndicatorShape.circle,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
  });

  PageIndicatorStyle copyWith({
    Color? activeColor,
    Color? inactiveColor,
    double? activeSize,
    double? inactiveSize,
    double? spacing,
    IndicatorShape? shape,
    Duration? animationDuration,
    Curve? animationCurve,
  }) {
    return PageIndicatorStyle(
      activeColor: activeColor ?? this.activeColor,
      inactiveColor: inactiveColor ?? this.inactiveColor,
      activeSize: activeSize ?? this.activeSize,
      inactiveSize: inactiveSize ?? this.inactiveSize,
      spacing: spacing ?? this.spacing,
      shape: shape ?? this.shape,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
    );
  }
}

/// Shape options for page indicators
enum IndicatorShape {
  circle,
  rectangle,
  line,
}
