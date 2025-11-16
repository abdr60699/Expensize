# Changelog

All notable changes to the Social Auth module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-11-13

### Added
- Initial release of Social Auth module
- Google Sign-In integration with full OAuth 2.0 support
- Apple Sign-In for iOS, macOS, and Web
- Facebook Login with Graph API integration
- Adapter-based architecture for extensibility
- Pluggable backend system (Firebase Auth + REST API examples)
- Secure token storage with flutter_secure_storage
- Customizable UI components (buttons and button rows)
- Platform-aware compatibility checks
- Comprehensive error handling with custom error types
- Example application with login and profile screens
- Unit tests with Mockito mocks
- Widget tests for UI components
- Complete setup documentation

### Core Components
- `SocialAuth` - Main facade with singleton pattern
- `BaseAuthAdapter` - Base interface for all providers
- `GoogleAuthAdapter` - Google Sign-In implementation
- `AppleAuthAdapter` - Apple Sign-In implementation
- `FacebookAuthAdapter` - Facebook Login implementation
- `SocialAuthManager` - Provider orchestration
- `AuthService` - Backend integration interface
- `TokenStorage` - Secure token persistence
- `SocialSignInButton` - Customizable provider button
- `SocialSignInRow` - Multiple provider buttons

### Backend Integration
- `FirebaseAuthService` - Firebase Auth integration example
- `RestApiAuthService` - Custom REST API integration example
- Token verification examples for all providers

### Dependencies
- google_sign_in: ^6.1.5
- sign_in_with_apple: ^5.0.0
- flutter_facebook_auth: ^6.0.3
- firebase_auth: ^4.15.0 (optional)
- flutter_secure_storage: ^9.0.0
- http: ^1.1.2

### Documentation
- 650+ line README with complete setup guide
- Platform-specific configuration (Android, iOS, Web)
- Backend integration examples with code samples
- Server-side token verification code (Python)
- Security best practices
- API reference
- Troubleshooting guide
- Example app documentation
- Test suite documentation

### Testing
- Google adapter tests
- Apple adapter tests
- Facebook adapter tests
- Manager orchestration tests
- Widget interaction tests
- Mock generation with build_runner

## [Unreleased]

### Planned
- Twitter/X authentication
- GitHub OAuth
- Microsoft account integration
- Biometric authentication option
- Advanced token refresh strategies
- Session management utilities
