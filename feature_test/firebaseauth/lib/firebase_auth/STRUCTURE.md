# Firebase Auth Module - Folder Structure

```
lib/features/firebase_auth/
├── firebase_auth.dart                    # Public API entry point (exports all public classes)
├── README.md                             # Integration guide, platform setup, usage examples
├── models/
│   ├── user_model.dart                   # Domain UserModel (uid, email, phone, providers, etc.)
│   └── auth_result.dart                  # AuthResult wrapper for operation results
├── errors/
│   └── auth_error.dart                   # AuthError, AuthErrorCode, error mapping
├── storage/
│   ├── token_store.dart                  # ITokenStore interface
│   ├── secure_storage_token_store.dart   # Implementation using flutter_secure_storage
│   └── shared_prefs_session_store.dart   # Simple session storage using shared_preferences
├── repository/
│   └── auth_repository.dart              # Maps Firebase SDK to domain models, handles persistence
├── services/
│   ├── auth_service.dart                 # Main facade: signUpWithEmail, signInWithPhone, etc.
│   ├── social_auth/
│   │   ├── google_signin_adapter.dart    # Google Sign-In adapter
│   │   ├── apple_signin_adapter.dart     # Apple Sign-In adapter
│   │   └── facebook_signin_adapter.dart  # Facebook Sign-In adapter
│   └── phone_auth_service.dart           # Phone OTP flow handler
├── providers/
│   ├── auth_providers.dart               # Riverpod providers
│   └── getit_registration.dart           # GetIt DI registration helper
├── ui/
│   ├── screens/
│   │   ├── sign_in_screen.dart           # Email/Password sign-in screen
│   │   ├── sign_up_screen.dart           # Email/Password sign-up screen
│   │   ├── phone_signin_screen.dart      # Phone OTP screen
│   │   └── profile_screen.dart           # User profile with link/unlink options
│   ├── widgets/
│   │   ├── auth_text_field.dart          # Reusable text field with validation
│   │   ├── social_signin_buttons.dart    # Google, Apple, Facebook buttons
│   │   └── link_account_dialog.dart      # Dialog for linking accounts
│   └── auth_ui_kit.dart                  # Export all UI widgets
└── utils/
    ├── validators.dart                   # Email, password, phone validators
    └── auth_constants.dart               # Constants (error messages, etc.)

test/
├── unit/
│   ├── auth_service_test.dart            # Unit tests for AuthService
│   ├── auth_repository_test.dart         # Repository tests
│   ├── token_store_test.dart             # Token storage tests
│   └── validators_test.dart              # Validator tests
└── widget/
    ├── sign_in_screen_test.dart          # Widget tests for sign-in
    └── sign_up_screen_test.dart          # Widget tests for sign-up

example/
└── main.dart                             # Example app showing Riverpod & GetIt wiring
```

## File Descriptions

### Core Files
- **firebase_auth.dart**: Single import point for the entire module
- **README.md**: Complete integration guide with platform setup

### Models
- **user_model.dart**: Serializable user domain model (no Firebase dependencies)
- **auth_result.dart**: Wrapper for operation results with success/error states

### Errors
- **auth_error.dart**: Normalized error codes, friendly messages, recovery suggestions

### Storage
- **token_store.dart**: Interface for token/session persistence
- **secure_storage_token_store.dart**: Secure implementation for tokens
- **shared_prefs_session_store.dart**: Simple session metadata storage

### Repository
- **auth_repository.dart**: Translates Firebase User to UserModel, handles caching & persistence

### Services
- **auth_service.dart**: Main API facade with all auth operations
- **social_auth/**: Adapters for Google, Apple, Facebook sign-in
- **phone_auth_service.dart**: Phone OTP verification flow handler

### Providers
- **auth_providers.dart**: Riverpod providers for DI
- **getit_registration.dart**: GetIt registration helper

### UI
- **screens/**: Complete example screens (sign-in, sign-up, phone, profile)
- **widgets/**: Reusable UI components
- **auth_ui_kit.dart**: Exports all UI components

### Utils
- **validators.dart**: Input validation logic
- **auth_constants.dart**: Shared constants

### Tests
- **unit/**: Unit tests with mocks
- **widget/**: Widget tests for UI flows
