import 'package:flutter/material.dart';
import 'dart:io';

/// Collection of social sign-in buttons
///
/// Provides consistent styling and branding for social providers.

/// Google Sign-In button
class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final String text;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.text = 'Continue with Google',
  });

  @override
  Widget build(BuildContext context) {
    return _SocialSignInButton(
      onPressed: isLoading ? null : onPressed,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      icon: Icons.g_mobiledata,
      text: text,
      isLoading: isLoading,
      borderColor: Colors.grey.shade300,
    );
  }
}

/// Apple Sign-In button
class AppleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final String text;

  const AppleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.text = 'Continue with Apple',
  });

  @override
  Widget build(BuildContext context) {
    // Only show on supported platforms
    if (!Platform.isIOS && !Platform.isMacOS) {
      return const SizedBox.shrink();
    }

    return _SocialSignInButton(
      onPressed: isLoading ? null : onPressed,
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      icon: Icons.apple,
      text: text,
      isLoading: isLoading,
    );
  }
}

/// Facebook Sign-In button
class FacebookSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final String text;

  const FacebookSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.text = 'Continue with Facebook',
  });

  @override
  Widget build(BuildContext context) {
    return _SocialSignInButton(
      onPressed: isLoading ? null : onPressed,
      backgroundColor: const Color(0xFF1877F2),
      foregroundColor: Colors.white,
      icon: Icons.facebook,
      text: text,
      isLoading: isLoading,
    );
  }
}

/// Generic social sign-in button
class _SocialSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;
  final String text;
  final bool isLoading;
  final Color? borderColor;

  const _SocialSignInButton({
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    required this.text,
    this.isLoading = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          side: borderColor != null
              ? BorderSide(color: borderColor!, width: 1)
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 1,
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: foregroundColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Divider with "OR" text
class OrDivider extends StatelessWidget {
  final String text;

  const OrDivider({
    super.key,
    this.text = 'OR',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

/// Collection of all social sign-in buttons
class SocialSignInButtons extends StatelessWidget {
  final VoidCallback onGooglePressed;
  final VoidCallback? onApplePressed;
  final VoidCallback onFacebookPressed;
  final bool isLoading;
  final bool showDivider;

  const SocialSignInButtons({
    super.key,
    required this.onGooglePressed,
    this.onApplePressed,
    required this.onFacebookPressed,
    this.isLoading = false,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showDivider) ...[
          const OrDivider(),
          const SizedBox(height: 16),
        ],
        GoogleSignInButton(
          onPressed: onGooglePressed,
          isLoading: isLoading,
        ),
        const SizedBox(height: 12),
        if (onApplePressed != null && (Platform.isIOS || Platform.isMacOS)) ...[
          AppleSignInButton(
            onPressed: onApplePressed!,
            isLoading: isLoading,
          ),
          const SizedBox(height: 12),
        ],
        FacebookSignInButton(
          onPressed: onFacebookPressed,
          isLoading: isLoading,
        ),
      ],
    );
  }
}
