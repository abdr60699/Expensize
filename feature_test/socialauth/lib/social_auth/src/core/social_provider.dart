/// Social authentication provider types
enum SocialProvider {
  google,
  apple,
  facebook,
}

extension SocialProviderExtension on SocialProvider {
  String get name {
    switch (this) {
      case SocialProvider.google:
        return 'Google';
      case SocialProvider.apple:
        return 'Apple';
      case SocialProvider.facebook:
        return 'Facebook';
    }
  }

  String get id {
    switch (this) {
      case SocialProvider.google:
        return 'google';
      case SocialProvider.apple:
        return 'apple';
      case SocialProvider.facebook:
        return 'facebook';
    }
  }
}
