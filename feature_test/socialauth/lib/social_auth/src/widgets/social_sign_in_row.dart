import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../core/social_provider.dart';
import 'social_sign_in_button.dart';

/// Row of social sign-in buttons
class SocialSignInRow extends StatelessWidget {
  final Function(SocialProvider)? onProviderSelected;
  final List<SocialProvider> providers;
  final bool showAppleOnlyOnIOS;
  final Map<SocialProvider, bool> loadingStates;
  final double buttonHeight;
  final double spacing;
  final EdgeInsetsGeometry? padding;

  const SocialSignInRow({
    Key? key,
    this.onProviderSelected,
    this.providers = const [
      SocialProvider.google,
      SocialProvider.apple,
      SocialProvider.facebook,
    ],
    this.showAppleOnlyOnIOS = true,
    this.loadingStates = const {},
    this.buttonHeight = 50,
    this.spacing = 12,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final visibleProviders = _getVisibleProviders();

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: visibleProviders
            .map((provider) => Padding(
                  padding: EdgeInsets.only(
                    bottom: provider == visibleProviders.last ? 0 : spacing,
                  ),
                  child: SocialSignInButton(
                    provider: provider,
                    onPressed: () => onProviderSelected?.call(provider),
                    isLoading: loadingStates[provider] ?? false,
                    height: buttonHeight,
                  ),
                ))
            .toList(),
      ),
    );
  }

  List<SocialProvider> _getVisibleProviders() {
    List<SocialProvider> visibleProviders = List.from(providers);

    // Filter Apple based on platform
    if (showAppleOnlyOnIOS) {
      if (!_isAppleAvailable()) {
        visibleProviders.remove(SocialProvider.apple);
      }
    }

    return visibleProviders;
  }

  bool _isAppleAvailable() {
    if (kIsWeb) return false;

    try {
      return Platform.isIOS || Platform.isMacOS;
    } catch (e) {
      return false;
    }
  }
}
