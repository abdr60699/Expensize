# Changelog

All notable changes to the Supabase Auth module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-11-13

### Added
- Initial release of Supabase Auth module
- Email/password authentication (signup and signin)
- Magic link (passwordless) authentication
- OAuth provider support (Google, Apple, Facebook, Twitter, GitHub)
- Password reset functionality
- Email verification support
- **Sign out functionality with session cleanup**
- Reactive auth state management with streams
- Secure token storage with flutter_secure_storage
- Configurable password requirements
- Client-side email and password validation
- ReusableSignInScreen widget
- ReusableSignUpScreen widget with password strength indicator
- ReusableForgotPasswordScreen widget
- ReusableAuthGuard widget for protected routes
- AuthRepository facade pattern
- SupabaseAuthService implementation
- TokenStorage interface with SecureTokenStorage and MemoryTokenStorage
- Comprehensive error handling with AuthError types
- Session management and automatic token refresh
- User metadata updates
- OTP verification support

### Core Components
- `AuthService` - Abstract interface for auth operations
- `SupabaseAuthService` - Supabase backend implementation
- `AuthRepository` - Facade with reactive state management
- `SupabaseAuthConfig` - Flexible configuration system
- `AuthResult` - Authentication result model
- `AuthUser` - User data model
- `AuthError` - Custom error types with clear codes
- `Validators` - Email and password validation utilities
- `TokenStorage` - Secure token persistence
- `ReusableSignInScreen` - Pre-built sign-in UI

### Dependencies
- supabase_flutter: ^2.0.0
- flutter_secure_storage: ^9.0.0
- logger: ^2.0.2

### Documentation
- Comprehensive README with setup guide
- Platform-specific configuration instructions (Android/iOS)
- API reference for all public methods
- Security best practices guide
- Integration checklist
- Migration guide for custom backends
- Quick start examples

### Features
- Stream-based auth state changes
- Environment variable configuration
- Customizable password requirements
- Platform-aware OAuth handling
- Deep linking support for OAuth callbacks
- Rate limit error handling
- Session expiration handling
- User metadata support

## [Unreleased]

### Planned
- ReusableSignUpScreen widget
- ReusableForgotPasswordScreen widget
- SocialSignInButtons widget
- AuthGuard widget for route protection
- Biometric authentication support
- Multi-factor authentication (MFA)
- Phone number authentication
- Account linking utilities
- Comprehensive test suite
- Example application
- Server-side integration examples
- CI/CD configuration
