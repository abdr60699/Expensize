/// Enum representing social authentication providers
enum SocialProvider {
  google,
  apple,
  facebook,
  twitter,
  github,
}

extension SocialProviderExtension on SocialProvider {
  /// Human-readable name of the provider
  String get name {
    switch (this) {
      case SocialProvider.google:
        return 'Google';
      case SocialProvider.apple:
        return 'Apple';
      case SocialProvider.facebook:
        return 'Facebook';
      case SocialProvider.twitter:
        return 'Twitter';
      case SocialProvider.github:
        return 'GitHub';
    }
  }

  /// Provider ID used by Supabase
  String get id {
    switch (this) {
      case SocialProvider.google:
        return 'google';
      case SocialProvider.apple:
        return 'apple';
      case SocialProvider.facebook:
        return 'facebook';
      case SocialProvider.twitter:
        return 'twitter';
      case SocialProvider.github:
        return 'github';
    }
  }
}
