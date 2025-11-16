import 'package:flutter/material.dart';

/// A numeric PIN pad widget
///
/// Displays a 3x4 grid of buttons for entering PIN digits.
/// Includes numbers 0-9, backspace, and optional custom action button.
class PinPad extends StatelessWidget {
  /// Callback when a digit is entered
  final ValueChanged<String> onDigitPressed;

  /// Callback when backspace is pressed
  final VoidCallback onBackspace;

  /// Optional custom action button (e.g., "Forgot PIN")
  final Widget? customActionButton;

  /// Optional callback for custom action
  final VoidCallback? onCustomAction;

  /// Button color
  final Color? buttonColor;

  /// Text color
  final Color? textColor;

  /// Button size
  final double buttonSize;

  /// Whether buttons are enabled
  final bool enabled;

  const PinPad({
    super.key,
    required this.onDigitPressed,
    required this.onBackspace,
    this.customActionButton,
    this.onCustomAction,
    this.buttonColor,
    this.textColor,
    this.buttonSize = 70,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveButtonColor = buttonColor ??
        theme.colorScheme.primary.withOpacity(0.1);
    final effectiveTextColor = textColor ?? theme.colorScheme.onSurface;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Row 1: 1, 2, 3
        _buildRow(['1', '2', '3'], effectiveButtonColor, effectiveTextColor),
        const SizedBox(height: 16),

        // Row 2: 4, 5, 6
        _buildRow(['4', '5', '6'], effectiveButtonColor, effectiveTextColor),
        const SizedBox(height: 16),

        // Row 3: 7, 8, 9
        _buildRow(['7', '8', '9'], effectiveButtonColor, effectiveTextColor),
        const SizedBox(height: 16),

        // Row 4: custom/empty, 0, backspace
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Custom action or empty space
            if (customActionButton != null && onCustomAction != null)
              SizedBox(
                width: buttonSize,
                height: buttonSize,
                child: IconButton(
                  onPressed: enabled ? onCustomAction : null,
                  icon: customActionButton!,
                  iconSize: buttonSize * 0.4,
                ),
              )
            else
              SizedBox(width: buttonSize, height: buttonSize),

            // Zero button
            _buildButton('0', effectiveButtonColor, effectiveTextColor),

            // Backspace button
            SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: IconButton(
                onPressed: enabled ? onBackspace : null,
                icon: const Icon(Icons.backspace_outlined),
                iconSize: buttonSize * 0.4,
                color: effectiveTextColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(
    List<String> digits,
    Color buttonColor,
    Color textColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits
          .map((digit) => _buildButton(digit, buttonColor, textColor))
          .toList(),
    );
  }

  Widget _buildButton(String digit, Color buttonColor, Color textColor) {
    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: Material(
        color: buttonColor,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: enabled ? () => onDigitPressed(digit) : null,
          customBorder: const CircleBorder(),
          child: Center(
            child: Text(
              digit,
              style: TextStyle(
                fontSize: buttonSize * 0.35,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
