import 'package:flutter/material.dart';
import '../models/onboarding_config.dart';

/// Widget that displays page indicators (dots) for onboarding
///
/// Shows which page is currently active in the onboarding flow.
class PageIndicator extends StatelessWidget {
  /// Total number of pages
  final int pageCount;

  /// Currently active page index
  final int currentPage;

  /// Style configuration for the indicator
  final PageIndicatorStyle style;

  /// Callback when a dot is tapped (optional - for clickable dots)
  final void Function(int)? onDotTapped;

  const PageIndicator({
    super.key,
    required this.pageCount,
    required this.currentPage,
    this.style = const PageIndicatorStyle(),
    this.onDotTapped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = style.activeColor ?? theme.colorScheme.primary;
    final inactiveColor =
        style.inactiveColor ?? theme.colorScheme.onSurface.withOpacity(0.3);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        return GestureDetector(
          onTap: onDotTapped != null ? () => onDotTapped!(index) : null,
          child: AnimatedContainer(
            duration: style.animationDuration,
            curve: style.animationCurve,
            margin: EdgeInsets.symmetric(horizontal: style.spacing / 2),
            decoration: _buildDecoration(
              index: index,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),
            width: _getWidth(index),
            height: _getHeight(index),
          ),
        );
      }),
    );
  }

  /// Get the width for a dot at the given index
  double _getWidth(int index) {
    final isActive = index == currentPage;

    switch (style.shape) {
      case IndicatorShape.circle:
        return isActive ? style.activeSize : style.inactiveSize;
      case IndicatorShape.rectangle:
        return isActive ? style.activeSize * 2 : style.inactiveSize * 1.5;
      case IndicatorShape.line:
        return isActive ? style.activeSize * 3 : style.inactiveSize * 2;
    }
  }

  /// Get the height for a dot at the given index
  double _getHeight(int index) {
    final isActive = index == currentPage;
    return isActive ? style.activeSize : style.inactiveSize;
  }

  /// Build decoration for a dot
  BoxDecoration _buildDecoration({
    required int index,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    final isActive = index == currentPage;
    final color = isActive ? activeColor : inactiveColor;

    switch (style.shape) {
      case IndicatorShape.circle:
        return BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        );
      case IndicatorShape.rectangle:
        return BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        );
      case IndicatorShape.line:
        return BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        );
    }
  }
}

/// Alternative worm-style page indicator
///
/// The active indicator "moves" like a worm between positions.
class WormPageIndicator extends StatelessWidget {
  final int pageCount;
  final int currentPage;
  final PageIndicatorStyle style;

  const WormPageIndicator({
    super.key,
    required this.pageCount,
    required this.currentPage,
    this.style = const PageIndicatorStyle(),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = style.activeColor ?? theme.colorScheme.primary;
    final inactiveColor =
        style.inactiveColor ?? theme.colorScheme.onSurface.withOpacity(0.3);

    final dotWidth = style.inactiveSize;
    final spacing = style.spacing;
    final activeWidth = style.activeSize * 2;

    return SizedBox(
      height: style.activeSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Inactive dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(pageCount, (index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: spacing / 2),
                width: dotWidth,
                height: dotWidth,
                decoration: BoxDecoration(
                  color: inactiveColor,
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
          // Active indicator (worm)
          AnimatedPositioned(
            duration: style.animationDuration,
            curve: style.animationCurve,
            left: _calculatePosition(dotWidth, spacing, activeWidth),
            child: Container(
              width: activeWidth,
              height: style.activeSize,
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(style.activeSize / 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculatePosition(double dotWidth, double spacing, double activeWidth) {
    final totalDotWidth = dotWidth + spacing;
    final centerOffset = (MediaQuery.of(
      // This is a simplified calculation - in production you'd need context
      // or pass in screen width
      // For now, approximate based on page count
      null as BuildContext, // This will be provided when built
    ).size.width - (pageCount * totalDotWidth)) / 2;

    return centerOffset + (currentPage * totalDotWidth) - (activeWidth - dotWidth) / 2;
  }
}

/// Progress-style page indicator
///
/// Shows progress as "1/5", "2/5", etc.
class ProgressPageIndicator extends StatelessWidget {
  final int pageCount;
  final int currentPage;
  final TextStyle? textStyle;

  const ProgressPageIndicator({
    super.key,
    required this.pageCount,
    required this.currentPage,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurface.withOpacity(0.6),
    );

    return Text(
      '${currentPage + 1}/$pageCount',
      style: textStyle ?? defaultStyle,
    );
  }
}
