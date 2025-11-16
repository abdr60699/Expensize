import 'package:flutter/material.dart';
import '../core/social_provider.dart';

/// Social sign-in button widget
class SocialSignInButton extends StatelessWidget {
  final SocialProvider provider;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final double height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final TextStyle? textStyle;
  final Widget? customIcon;
  final String? customLabel;

  const SocialSignInButton({
    Key? key,
    required this.provider,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.height = 50,
    this.width,
    this.padding,
    this.borderRadius,
    this.textStyle,
    this.customIcon,
    this.customLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = _getProviderConfig();

    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        onPressed: (isDisabled || isLoading) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: config.backgroundColor,
          foregroundColor: config.foregroundColor,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    config.foregroundColor,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  customIcon ?? _buildIcon(config),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      customLabel ?? config.label,
                      style: textStyle ??
                          TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: config.foregroundColor,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildIcon(_ProviderConfig config) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: config.iconBackgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        config.icon,
        size: 18,
        color: config.iconColor,
      ),
    );
  }

  _ProviderConfig _getProviderConfig() {
    switch (provider) {
      case SocialProvider.google:
        return _ProviderConfig(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          icon: Icons.g_mobiledata,
          iconColor: Colors.black87,
          iconBackgroundColor: Colors.white,
          label: 'Continue with Google',
        );

      case SocialProvider.apple:
        return _ProviderConfig(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          icon: Icons.apple,
          iconColor: Colors.white,
          iconBackgroundColor: Colors.black,
          label: 'Continue with Apple',
        );

      case SocialProvider.facebook:
        return _ProviderConfig(
          backgroundColor: const Color(0xFF1877F2),
          foregroundColor: Colors.white,
          icon: Icons.facebook,
          iconColor: Colors.white,
          iconBackgroundColor: const Color(0xFF1877F2),
          label: 'Continue with Facebook',
        );
    }
  }
}

class _ProviderConfig {
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String label;

  _ProviderConfig({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.label,
  });
}
