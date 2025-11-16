# Supabase Auth Module - Integration Checklist

Use this checklist when integrating the Supabase Auth module into your Flutter application.

## ✅ Pre-Integration

- [ ] Have a Supabase account (sign up at [supabase.com](https://supabase.com))
- [ ] Created a Supabase project
- [ ] Have your Supabase URL and anon key ready
- [ ] Decided which authentication methods to enable (email, OAuth, magic link)
- [ ] Reviewed the [main README](README.md) for overview

## ✅ Module Setup

### 1. Add Dependency

- [ ] Added module to `pubspec.yaml`:
  ```yaml
  dependencies:
    supabase_auth:
      path: ../modules/supabase_auth
  ```
- [ ] Ran `flutter pub get`

### 2. Environment Configuration

- [ ] Created `.env` file or configuration file
- [ ] Added `SUPABASE_URL` to configuration
- [ ] Added `SUPABASE_ANON_KEY` to configuration
- [ ] Added `.env` to `.gitignore`
- [ ] (Optional) Set up `SUPABASE_REDIRECT_URL` for OAuth

## ✅ Supabase Dashboard Configuration

### Email Authentication

- [ ] Went to Authentication → Providers in Supabase Dashboard
- [ ] Enabled "Email" provider
- [ ] Configured email templates (optional)
- [ ] Decided whether to require email confirmation
- [ ] Tested sending test email (Settings → Auth → Email)

### OAuth Providers (if using)

#### Google

- [ ] Enabled Google provider in Supabase Dashboard
- [ ] Created Google Cloud project
- [ ] Configured OAuth consent screen
- [ ] Created OAuth 2.0 Client ID
- [ ] Added authorized redirect URIs in Google Console
- [ ] Added Client ID and Secret to Supabase Dashboard
- [ ] Saved configuration

#### Apple

- [ ] Enabled Apple provider in Supabase Dashboard
- [ ] Created Apple Developer account
- [ ] Created Services ID in Apple Developer portal
- [ ] Configured Sign in with Apple
- [ ] Added redirect URLs
- [ ] Created and downloaded private key
- [ ] Added Service ID, Team ID, and Key to Supabase Dashboard
- [ ] Enabled Sign In with Apple capability in Xcode

#### Facebook

- [ ] Enabled Facebook provider in Supabase Dashboard
- [ ] Created Facebook app at developers.facebook.com
- [ ] Configured Facebook Login product
- [ ] Added OAuth redirect URIs
- [ ] Added App ID and App Secret to Supabase Dashboard
- [ ] Configured app settings

#### Twitter / GitHub (if using)

- [ ] Enabled provider in Supabase Dashboard
- [ ] Created OAuth app in provider's developer portal
- [ ] Configured callback URLs
- [ ] Added credentials to Supabase Dashboard

## ✅ Android Configuration

- [ ] Added internet permission in `AndroidManifest.xml`:
  ```xml
  <uses-permission android:name="android.permission.INTERNET"/>
  ```

### For OAuth (if using)

- [ ] Added intent filter for deep links in `AndroidManifest.xml`:
  ```xml
  <intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="your-app" android:host="auth-callback" />
  </intent-filter>
  ```
- [ ] Updated `android:scheme` to match your app
- [ ] (For Google) Generated SHA-1 certificate fingerprint
- [ ] (For Google) Added SHA-1 to Firebase/Google Console
- [ ] (For Facebook) Generated key hash
- [ ] (For Facebook) Added key hash to Facebook app settings

## ✅ iOS Configuration

- [ ] Set minimum deployment target to iOS 13+ (for Apple Sign In)

### For OAuth (if using)

- [ ] Added URL scheme in `Info.plist`:
  ```xml
  <key>CFBundleURLTypes</key>
  <array>
    <dict>
      <key>CFBundleTypeRole</key>
      <string>Editor</string>
      <key>CFBundleURLSchemes</key>
      <array>
        <string>your-app</string>
      </array>
    </dict>
  </array>
  ```
- [ ] Updated URL scheme to match your app
- [ ] (For Apple) Enabled Sign In with Apple capability in Xcode
- [ ] (For Apple) Added entitlements
- [ ] (For Google) Added reversed client ID scheme
- [ ] (For Facebook) Configured Facebook SDK in Info.plist

## ✅ Code Integration

### Initialization

- [ ] Imported the module:
  ```dart
  import 'package:supabase_auth/supabase_auth.dart';
  ```
- [ ] Initialized in `main()`:
  ```dart
  await AuthRepository.initialize(
    SupabaseAuthConfig(
      supabaseUrl: 'YOUR_URL',
      supabaseAnonKey: 'YOUR_KEY',
      // ... other config
    ),
  );
  ```
- [ ] Configured enabled providers
- [ ] Set password requirements
- [ ] Configured secure storage option
- [ ] Added error handling for initialization

### Auth State Management

- [ ] Set up `StreamBuilder` for auth state:
  ```dart
  StreamBuilder<AuthResult?>(
    stream: AuthRepository.instance.authStateChanges(),
    builder: (context, snapshot) {
      // Handle signed in / signed out states
    },
  )
  ```
- [ ] Implemented navigation logic (signed in → home, signed out → login)
- [ ] Handle loading state
- [ ] Handle errors

### Sign Up Flow

- [ ] Added `ReusableSignUpScreen` or custom sign up UI
- [ ] Implemented `onSignedUp` callback
- [ ] Implemented `onError` callback
- [ ] Added navigation after successful signup
- [ ] Configured password requirements
- [ ] Added terms and conditions checkbox (if required)
- [ ] Tested sign up flow

### Sign In Flow

- [ ] Added `ReusableSignInScreen` or custom sign in UI
- [ ] Implemented `onSignedIn` callback
- [ ] Implemented `onError` callback
- [ ] Added forgot password navigation
- [ ] Added sign up navigation
- [ ] Tested sign in flow with valid credentials
- [ ] Tested sign in flow with invalid credentials

### Forgot Password Flow

- [ ] Added `ReusableForgotPasswordScreen` or custom UI
- [ ] Implemented password reset email sending
- [ ] Added success message/screen
- [ ] Tested email receiving
- [ ] Tested password reset link
- [ ] Tested signing in with new password

### OAuth Flow (if using)

- [ ] Implemented OAuth sign-in buttons
- [ ] Added provider selection UI
- [ ] Configured redirect handling
- [ ] Tested each OAuth provider on device
- [ ] Handle OAuth cancellation
- [ ] Handle OAuth errors

### Sign Out

- [ ] Implemented sign out functionality
- [ ] Called `AuthRepository.instance.signOut()`
- [ ] Cleared user data/cache
- [ ] Navigated back to login screen
- [ ] Tested sign out flow

## ✅ Testing

### Unit Testing

- [ ] Reviewed example tests in module
- [ ] (Optional) Added custom tests for your integration
- [ ] Tested validators
- [ ] Tested error handling

### Manual Testing

#### Email/Password

- [ ] Sign up with valid email and password
- [ ] Verify email confirmation (if enabled)
- [ ] Sign in with correct credentials
- [ ] Sign in with wrong password (should fail)
- [ ] Sign in with non-existent email (should fail)
- [ ] Sign out
- [ ] Test forgot password flow
- [ ] Reset password and sign in with new password

#### OAuth (for each enabled provider)

- [ ] Initiate OAuth flow
- [ ] Complete authentication in provider
- [ ] Verify redirect back to app
- [ ] Verify user data populated
- [ ] Test sign out
- [ ] Test sign in again (should be faster)
- [ ] Test cancelling OAuth flow

#### Edge Cases

- [ ] Test without internet connection
- [ ] Test with slow internet
- [ ] Test rate limiting (many failed attempts)
- [ ] Test session expiration
- [ ] Test concurrent sign-in attempts
- [ ] Test app restart (session persistence)

### Device Testing

- [ ] Tested on physical Android device
- [ ] Tested on physical iOS device
- [ ] Tested on Android emulator
- [ ] Tested on iOS simulator
- [ ] (Optional) Tested on web
- [ ] (Optional) Tested on desktop

## ✅ Security Review

- [ ] Reviewed security best practices in README
- [ ] Environment variables not committed to git
- [ ] Using secure token storage
- [ ] Password requirements meet security standards
- [ ] Email confirmation enabled (for production)
- [ ] HTTPS used for all endpoints
- [ ] No sensitive data logged in production
- [ ] OAuth redirect URLs properly configured
- [ ] Supabase Row Level Security (RLS) configured (if using database)

## ✅ Production Preparation

- [ ] Removed debug logging
- [ ] Configured production Supabase project
- [ ] Updated environment variables for production
- [ ] Tested with production credentials
- [ ] Configured email sender (SMTP) for production
- [ ] Set up monitoring/analytics (optional)
- [ ] Prepared user documentation
- [ ] Configured app store OAuth settings (for mobile)

## ✅ Documentation

- [ ] Documented authentication flow in project README
- [ ] Added setup instructions for new developers
- [ ] Documented environment variable requirements
- [ ] Created troubleshooting guide (optional)
- [ ] Documented OAuth provider setup steps

## ✅ Optional Enhancements

- [ ] Added biometric authentication
- [ ] Implemented remember me functionality
- [ ] Added multi-factor authentication (MFA)
- [ ] Customized email templates
- [ ] Added social account linking
- [ ] Implemented user profile management
- [ ] Added phone number authentication
- [ ] Set up custom error messages
- [ ] Customized UI theme to match app
- [ ] Added analytics tracking

## 📋 Common Issues Checklist

If you encounter issues, verify:

- [ ] Supabase URL and anon key are correct
- [ ] Using anon key, not service role key
- [ ] Internet connection is available
- [ ] Supabase project is running (not paused)
- [ ] Email provider is enabled in Supabase Dashboard
- [ ] OAuth credentials are correctly entered
- [ ] Redirect URLs match exactly
- [ ] Platform configurations (Android/iOS) are complete
- [ ] All dependencies are installed (`flutter pub get`)
- [ ] Build is up to date (`flutter clean && flutter run`)

## 🎉 Integration Complete!

Once all items are checked:

- [ ] Committed changes to version control
- [ ] Performed final end-to-end testing
- [ ] Deployed to staging environment
- [ ] Conducted user acceptance testing
- [ ] Ready for production deployment

---

**Need Help?**
- Review the [Main README](README.md)
- Check the [Example App](example/README.md)
- Review [Supabase Auth Documentation](https://supabase.com/docs/guides/auth)
- Check your Supabase Dashboard for logs and errors
