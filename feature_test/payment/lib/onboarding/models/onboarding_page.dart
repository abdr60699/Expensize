import 'package:flutter/material.dart';

/// Represents a single page in the onboarding flow
///
/// Each page can display an image, title, description, and optional custom widget.
class OnboardingPage {
  /// Title text for this page
  final String title;

  /// Description/subtitle text for this page
  final String description;

  /// Optional image path (asset path)
  final String? imagePath;

  /// Optional image widget (use this OR imagePath, not both)
  final Widget? imageWidget;

  /// Optional icon to display instead of image
  final IconData? icon;

  /// Icon color (if using icon)
  final Color? iconColor;

  /// Icon size (if using icon)
  final double? iconSize;

  /// Background color for this page
  final Color? backgroundColor;

  /// Text color override for this page
  final Color? textColor;

  /// Custom widget to display instead of default layout
  /// If provided, this completely overrides the default page layout
  final Widget? customWidget;

  /// Additional data for analytics or custom logic
  final Map<String, dynamic>? metadata;

  const OnboardingPage({
    required this.title,
    required this.description,
    this.imagePath,
    this.imageWidget,
    this.icon,
    this.iconColor,
    this.iconSize,
    this.backgroundColor,
    this.textColor,
    this.customWidget,
    this.metadata,
  }) : assert(
          imagePath == null || imageWidget == null,
          'Cannot provide both imagePath and imageWidget',
        );

  /// Create a page with an asset image
  factory OnboardingPage.withImage({
    required String title,
    required String description,
    required String imagePath,
    Color? backgroundColor,
    Color? textColor,
    Map<String, dynamic>? metadata,
  }) {
    return OnboardingPage(
      title: title,
      description: description,
      imagePath: imagePath,
      backgroundColor: backgroundColor,
      textColor: textColor,
      metadata: metadata,
    );
  }

  /// Create a page with an icon
  factory OnboardingPage.withIcon({
    required String title,
    required String description,
    required IconData icon,
    Color? iconColor,
    double iconSize = 120.0,
    Color? backgroundColor,
    Color? textColor,
    Map<String, dynamic>? metadata,
  }) {
    return OnboardingPage(
      title: title,
      description: description,
      icon: icon,
      iconColor: iconColor,
      iconSize: iconSize,
      backgroundColor: backgroundColor,
      textColor: textColor,
      metadata: metadata,
    );
  }

  /// Create a page with a custom widget
  factory OnboardingPage.custom({
    required Widget widget,
    String title = '',
    String description = '',
    Map<String, dynamic>? metadata,
  }) {
    return OnboardingPage(
      title: title,
      description: description,
      customWidget: widget,
      metadata: metadata,
    );
  }

  /// Create a copy with modified fields
  OnboardingPage copyWith({
    String? title,
    String? description,
    String? imagePath,
    Widget? imageWidget,
    IconData? icon,
    Color? iconColor,
    double? iconSize,
    Color? backgroundColor,
    Color? textColor,
    Widget? customWidget,
    Map<String, dynamic>? metadata,
  }) {
    return OnboardingPage(
      title: title ?? this.title,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      imageWidget: imageWidget ?? this.imageWidget,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      iconSize: iconSize ?? this.iconSize,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      customWidget: customWidget ?? this.customWidget,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'OnboardingPage(title: $title, hasImage: ${imagePath != null || imageWidget != null}, hasIcon: ${icon != null})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OnboardingPage &&
        other.title == title &&
        other.description == description &&
        other.imagePath == imagePath &&
        other.icon == icon &&
        other.iconColor == iconColor &&
        other.iconSize == iconSize &&
        other.backgroundColor == backgroundColor &&
        other.textColor == textColor;
  }

  @override
  int get hashCode {
    return Object.hash(
      title,
      description,
      imagePath,
      icon,
      iconColor,
      iconSize,
      backgroundColor,
      textColor,
    );
  }
}
