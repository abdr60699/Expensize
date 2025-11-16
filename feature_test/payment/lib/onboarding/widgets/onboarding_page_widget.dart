import 'package:flutter/material.dart';
import '../models/onboarding_page.dart';
import '../models/onboarding_config.dart';

/// Widget that renders a single onboarding page
///
/// Displays the content (image/icon, title, description) for one page
/// in the onboarding flow.
class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;
  final OnboardingConfig config;

  const OnboardingPageWidget({
    super.key,
    required this.page,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    // If custom widget provided, use it
    if (page.customWidget != null) {
      return page.customWidget!;
    }

    final theme = Theme.of(context);
    final backgroundColor = page.backgroundColor;
    final textColor = page.textColor ?? theme.colorScheme.onBackground;

    return Container(
      color: backgroundColor,
      padding: config.contentPadding ??
          const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image/Icon section
          _buildMediaSection(context, textColor),

          SizedBox(height: config.imageTextSpacing),

          // Title
          _buildTitle(context, textColor),

          const SizedBox(height: 16),

          // Description
          _buildDescription(context, textColor),

          // Add flexible space to push content towards center
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildMediaSection(BuildContext context, Color textColor) {
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight * config.imageHeightRatio;

    return Flexible(
      flex: 2,
      child: Container(
        height: imageHeight,
        alignment: Alignment.center,
        child: _buildMedia(context, textColor),
      ),
    );
  }

  Widget _buildMedia(BuildContext context, Color textColor) {
    // Custom image widget
    if (page.imageWidget != null) {
      return page.imageWidget!;
    }

    // Asset image
    if (page.imagePath != null) {
      return Image.asset(
        page.imagePath!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.image_not_supported,
            size: 120,
            color: textColor.withOpacity(0.5),
          );
        },
      );
    }

    // Icon
    if (page.icon != null) {
      return Icon(
        page.icon!,
        size: page.iconSize ?? 120,
        color: page.iconColor ?? textColor,
      );
    }

    // No media - return empty container
    return const SizedBox.shrink();
  }

  Widget _buildTitle(BuildContext context, Color textColor) {
    final theme = Theme.of(context);
    final defaultStyle = theme.textTheme.headlineMedium?.copyWith(
      color: textColor,
      fontWeight: FontWeight.bold,
    );

    return Text(
      page.title,
      style: config.titleTextStyle ?? defaultStyle,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription(BuildContext context, Color textColor) {
    final theme = Theme.of(context);
    final defaultStyle = theme.textTheme.bodyLarge?.copyWith(
      color: textColor.withOpacity(0.8),
      height: 1.5,
    );

    return Text(
      page.description,
      style: config.descriptionTextStyle ?? defaultStyle,
      textAlign: TextAlign.center,
    );
  }
}
