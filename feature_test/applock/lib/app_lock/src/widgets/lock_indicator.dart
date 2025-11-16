import 'package:flutter/material.dart';

/// Visual indicator for PIN entry
///
/// Shows dots representing entered and remaining PIN digits.
class LockIndicator extends StatefulWidget {
  /// Current PIN length
  final int currentLength;

  /// Target PIN length (total number of dots to show)
  final int targetLength;

  /// Color for filled dots
  final Color? filledColor;

  /// Color for empty dots
  final Color? emptyColor;

  /// Size of each dot
  final double dotSize;

  /// Spacing between dots
  final double spacing;

  /// Whether to animate on change
  final bool animate;

  /// Whether to show error state (shake animation)
  final bool showError;

  /// Whether to show success state (checkmark)
  final bool showSuccess;

  const LockIndicator({
    super.key,
    required this.currentLength,
    required this.targetLength,
    this.filledColor,
    this.emptyColor,
    this.dotSize = 16,
    this.spacing = 12,
    this.animate = true,
    this.showError = false,
    this.showSuccess = false,
  });

  @override
  State<LockIndicator> createState() => _LockIndicatorState();
}

class _LockIndicatorState extends State<LockIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticIn,
      ),
    );
  }

  @override
  void didUpdateWidget(LockIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.showError && !oldWidget.showError) {
      _playShakeAnimation();
    }
  }

  void _playShakeAnimation() {
    _controller.reset();
    _controller.forward().then((_) {
      _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveFilledColor = widget.filledColor ?? theme.colorScheme.primary;
    final effectiveEmptyColor =
        widget.emptyColor ?? theme.colorScheme.onSurface.withOpacity(0.2);

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            widget.showError ? _shakeAnimation.value * ((_controller.value * 4).floor() % 2 == 0 ? 1 : -1) : 0,
            0,
          ),
          child: child,
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.targetLength,
          (index) => _buildDot(
            index < widget.currentLength,
            effectiveFilledColor,
            effectiveEmptyColor,
          ),
        ),
      ),
    );
  }

  Widget _buildDot(bool filled, Color filledColor, Color emptyColor) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
      child: AnimatedContainer(
        duration: widget.animate
            ? const Duration(milliseconds: 200)
            : Duration.zero,
        curve: Curves.easeInOut,
        width: widget.dotSize,
        height: widget.dotSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? filledColor : emptyColor,
          border: filled
              ? null
              : Border.all(
                  color: emptyColor,
                  width: 2,
                ),
        ),
        child: widget.showSuccess && filled
            ? Icon(
                Icons.check,
                size: widget.dotSize * 0.7,
                color: Colors.white,
              )
            : null,
      ),
    );
  }
}
