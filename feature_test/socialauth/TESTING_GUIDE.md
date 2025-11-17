# Social Authentication Module - Testing Guide

## Overview

This project contains a production-ready social authentication module for Flutter applications supporting:

1. **Google Sign-In** - OAuth 2.0 authentication for all platforms
2. **Apple Sign-In** - Native authentication for iOS/macOS, web flow for Android
3. **Facebook Login** - Social authentication for all platforms

## Features Implemented

### ✅ Google Sign-In
- All platforms supported (iOS, Android, Web)
- OAuth 2.0 authentication flow
- Customizable scopes (email, profile, etc.)
- Server auth code support
- Account selection on request
- Token refresh handling

### ✅ Apple Sign-In
- iOS 13+ native support
- macOS 10.15+ native support
- Android support via web authentication flow
- Web support with additional configuration
- Privacy-focused (email relay option)
- First-time user data capture
- Credential management

### ✅ Facebook Login
- All platforms supported
- Customizable permissions
- Profile data access (name, email, picture)
- Access token management
- Token expiration handling
- Account linking support

### ✅ Firebase Integration
- Optional Firebase Auth integration
- Account linking across providers
- Unified user management
- Provider credential management
- Sign-out across all providers

### ✅ Security Features
- Secure token storage (flutter_secure_storage)
- Token encryption at rest
- Automatic token refresh
- Secure credential handling
- Platform-specific security (Keychain/KeyStore)

## Dependencies (Latest Versions)

```yaml
dependencies:
  # Social Authentication
  google_sign_in: ^7.2.0
  sign_in_with_apple: ^7.0.1
  flutter_facebook_auth: ^7.1.2

  # Secure Storage
  flutter_secure_storage: ^9.2.4

  # Firebase (optional)
  firebase_core: ^4.2.1
  firebase_auth: ^6.1.2

  # HTTP client
  http: ^1.6.0
```

## Installation & Running

### 1. Install Dependencies

```bash
cd /home/user/Expensize/feature_test/socialauth
flutter pub get
```

### 2. Configure Firebase (Recommended)

#### Create Firebase Project
1. Go to https://console.firebase.google.com
2. Create new project or select existing
3. Add Android/iOS/Web apps

#### Download Configuration Files

**Android:**
- Download `google-services.json`
- Place in `android/app/`

**iOS:**
- Download `GoogleService-Info.plist`
- Place in `ios/Runner/`

**Web:**
- Copy Firebase config object
- Add to `web/index.html`

### 3. Configure Social Providers

#### Google Sign-In Setup

**Android:**
1. Get SHA-1 fingerprint:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
2. Add SHA-1 to Firebase Console (Project Settings > Your apps > Android app)
3. Download updated `google-services.json`

**iOS:**
1. Get OAuth client ID from Firebase Console
2. Add URL schemes to `ios/Runner/Info.plist`:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
       </array>
     </dict>
   </array>
   ```

**Web:**
1. Create OAuth 2.0 Client ID in Google Cloud Console
2. Add authorized JavaScript origins
3. Add authorized redirect URIs

#### Apple Sign-In Setup

**iOS/macOS:**
1. Enable "Sign in with Apple" capability in Xcode
2. Configure in Apple Developer Portal:
   - Enable Sign in with Apple for App ID
   - Create Sign in with Apple key

**Android/Web:**
1. Create Service ID in Apple Developer Portal
2. Configure return URLs
3. Set up client ID and redirect URI in code

**Configuration Required:**
```dart
SocialAuth(
  enableApple: true,
  appleClientId: 'com.your.app.service',  // Service ID
  appleRedirectUri: 'https://your-app.com/auth/callback',
);
```

#### Facebook Login Setup

1. Create Facebook App at https://developers.facebook.com
2. Add platforms (iOS, Android, Web)
3. Configure OAuth redirect URIs
4. Get App ID and App Secret

**Android:**
Add to `android/app/src/main/res/values/strings.xml`:
```xml
<string name="facebook_app_id">YOUR_APP_ID</string>
<string name="fb_login_protocol_scheme">fbYOUR_APP_ID</string>
<string name="facebook_client_token">YOUR_CLIENT_TOKEN</string>
```

Add to `AndroidManifest.xml`:
```xml
<meta-data android:name="com.facebook.sdk.ApplicationId" android:value="@string/facebook_app_id"/>
<meta-data android:name="com.facebook.sdk.ClientToken" android:value="@string/facebook_client_token"/>
```

**iOS:**
Add to `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>fbYOUR_APP_ID</string>
    </array>
  </dict>
</array>
<key>FacebookAppID</key>
<string>YOUR_APP_ID</string>
<key>FacebookDisplayName</key>
<string>YourAppName</string>
```

### 4. Run the App

```bash
# For Android
flutter run

# For iOS (requires Mac)
flutter run

# For Web
flutter run -d chrome

# List available devices
flutter devices
```

## Testing Checklist

### ✅ Google Sign-In

- [ ] App shows Google sign-in button
- [ ] Tapping button opens Google account picker
- [ ] Can select Google account
- [ ] Successfully receives user data (name, email)
- [ ] Access token is generated
- [ ] ID token is received
- [ ] Profile picture loads correctly
- [ ] Can sign out
- [ ] Can sign in again with different account
- [ ] Handles user cancellation gracefully
- [ ] Shows error messages appropriately

### ✅ Apple Sign-In

- [ ] Button shows on supported platforms
- [ ] Button disabled on unsupported platforms
- [ ] Opens Apple authentication (iOS/macOS)
- [ ] Opens web flow (Android)
- [ ] Receives user ID correctly
- [ ] Email received (if granted)
- [ ] Full name received on first sign-in
- [ ] Handles name privacy options
- [ ] ID token is generated
- [ ] Authorization code received
- [ ] Can sign out
- [ ] Handles user cancellation
- [ ] Shows platform warnings

### ✅ Facebook Login

- [ ] Facebook button visible
- [ ] Opens Facebook login dialog
- [ ] Can log in with Facebook credentials
- [ ] Receives user profile data
- [ ] Profile picture loads
- [ ] Email permission granted
- [ ] Access token generated
- [ ] Token expiration tracked
- [ ] Can sign out
- [ ] Can sign in again
- [ ] Handles cancellation
- [ ] Shows permission dialogs

### ✅ Firebase Integration

- [ ] Firebase initializes successfully
- [ ] Social auth links to Firebase account
- [ ] Firebase user created/signed in
- [ ] Firebase ID token generated
- [ ] Can link multiple providers
- [ ] Provider data synced
- [ ] Sign-out clears Firebase session
- [ ] Error handling for unlinked accounts

### ✅ UI/UX

- [ ] Loading indicators show during auth
- [ ] Success dialog shows user info
- [ ] Error dialogs show clear messages
- [ ] Platform support warnings visible
- [ ] User profile displays correctly
- [ ] Avatar/profile picture loads
- [ ] Sign-out button works
- [ ] Navigation flows smoothly
- [ ] Module info screen accessible

### ✅ Error Handling

- [ ] User cancellation handled
- [ ] Network errors shown
- [ ] Invalid credentials detected
- [ ] Platform not supported warnings
- [ ] Firebase not configured message
- [ ] Token errors handled
- [ ] Provider errors displayed

## Manual Test Scenarios

### Scenario 1: First-Time Google Sign-In
1. Launch app (should show Firebase not configured if not set up)
2. If Firebase configured, see social auth buttons
3. Tap "Sign in with Google"
4. Should open Google account picker
5. Select a Google account
6. Grant permissions if requested
7. Should return to app with success dialog
8. Verify user profile displays:
   - Name
   - Email
   - Profile picture
   - User ID
   - Access token (truncated)
9. Tap "Sign Out"
10. Should return to sign-in screen

### Scenario 2: Apple Sign-In (iOS/macOS)
1. Ensure running on iOS 13+ or macOS 10.15+
2. Tap "Sign in with Apple"
3. Should open Apple authentication
4. Authenticate with Face ID/Touch ID or password
5. Choose to share or hide email
6. Should return with success
7. Verify user data received (email may be hidden)
8. Note: Full name only on FIRST sign-in
9. Sign out successfully

### Scenario 3: Apple Sign-In (Android)
1. Run on Android device
2. Tap "Sign in with Apple"
3. Should open web authentication flow
4. Enter Apple ID credentials
5. Complete two-factor authentication
6. Grant permissions
7. Should redirect back to app
8. Verify authentication successful

### Scenario 4: Facebook Login
1. Tap "Sign in with Facebook"
2. Opens Facebook login dialog
3. Enter Facebook credentials
4. Grant requested permissions (email, public_profile)
5. Should return to app
6. Verify Facebook profile data:
   - Name from Facebook
   - Email if granted
   - Profile picture from Facebook
   - Facebook user ID
7. Sign out successfully

### Scenario 5: Firebase Integration
1. Ensure Firebase is configured
2. Sign in with Google
3. Verify Firebase user created
4. Check Firebase Console for user entry
5. Sign out
6. Sign in with different provider (Apple/Facebook)
7. Verify account linking (if same email)
8. Sign out from all providers

### Scenario 6: Error Handling
1. **Test Cancellation:**
   - Start sign-in flow
   - Cancel before completing
   - Should show cancellation message
   - Return to sign-in screen

2. **Test Network Error:**
   - Disable internet
   - Attempt sign-in
   - Should show network error
   - Enable internet and retry

3. **Test Platform Not Supported:**
   - Try Apple sign-in on Web (not configured)
   - Should show platform warning

### Scenario 7: Multiple Sign-Ins
1. Sign in with Google
2. Sign out
3. Sign in with Facebook
4. Sign out
5. Sign in with Apple
6. Verify each maintains separate session
7. Check token storage isolation

## Platform-Specific Features

### Android

**Features Available:**
- Google Sign-In (native)
- Apple Sign-In (web flow - requires configuration)
- Facebook Login (native)
- Secure token storage (KeyStore)

**Requirements:**
- Min SDK: 21 (Android 5.0+)
- Google Play Services for Google Sign-In
- Facebook SDK configured
- SHA-1 fingerprint registered

### iOS

**Features Available:**
- Google Sign-In (native)
- Apple Sign-In (native - iOS 13+)
- Facebook Login (native)
- Secure token storage (Keychain)

**Requirements:**
- iOS 13.0+ (for Apple Sign-In)
- URL schemes configured
- Capabilities enabled in Xcode
- CocoaPods dependencies

### Web

**Features Available:**
- Google Sign-In (OAuth)
- Apple Sign-In (requires Service ID)
- Facebook Login (JavaScript SDK)
- LocalStorage for tokens

**Limitations:**
- Apple Sign-In needs additional setup
- Token storage less secure
- Popup blockers may interfere

## Troubleshooting

### Issue: Google Sign-In fails immediately
**Solution:**
- Check SHA-1 fingerprint is registered (Android)
- Verify OAuth client ID configured (iOS)
- Ensure google-services.json is up to date
- Check Google Sign-In is enabled in Firebase Console

### Issue: Apple Sign-In not available
**Solution:**
- iOS: Check iOS version is 13+ or macOS 10.15+
- iOS: Verify capability is enabled in Xcode
- Android: Ensure Service ID and redirect URI configured
- Web: Check web authentication configuration

### Issue: Facebook Login shows error
**Solution:**
- Verify App ID is correct in configuration files
- Check Facebook App is in "Live" mode (not Development)
- Ensure OAuth redirect URIs are whitelisted
- Verify client token is configured
- Check Facebook SDK version compatibility

### Issue: Firebase not initialized
**Solution:**
- Ensure Firebase configuration files are present
- Android: google-services.json in android/app/
- iOS: GoogleService-Info.plist in ios/Runner/
- Run `flutter clean` and rebuild
- Check Firebase project is active

### Issue: Token storage fails
**Solution:**
- Check flutter_secure_storage is configured
- Android: Ensure min SDK 18+
- iOS: Check Keychain capabilities
- Clear app data and retry
- Verify permissions are granted

### Issue: User cancels sign-in but app crashes
**Solution:**
- Error handling implemented in main.dart
- Check logs for specific error
- Ensure SocialAuthError is caught
- Verify dialog dismissal works

### Issue: Profile picture not loading
**Solution:**
- Check network connection
- Verify image URL is valid
- Check CORS settings (web)
- Try caching the image
- Verify permissions granted for profile access

## Security Considerations

### ✅ Current Status
- Secure token storage implementation
- Token encryption at rest
- HTTPS for all API calls
- No credentials in code
- Platform-specific security (Keychain/KeyStore)

### ⚠️ For Production

1. **API Keys & Secrets:**
   - NEVER commit OAuth client secrets
   - Use environment variables
   - Server-side token validation
   - Rotate keys regularly

2. **Token Management:**
   - Implement token refresh logic
   - Set appropriate expiration times
   - Invalidate tokens on sign-out
   - Monitor for token leakage

3. **User Privacy:**
   - Request minimal permissions
   - Explain data usage clearly
   - Provide privacy policy
   - Allow data deletion

4. **Platform Security:**
   - Keep dependencies updated
   - Use latest SDK versions
   - Implement certificate pinning
   - Enable app protection (ProGuard, etc.)

## Performance

### Expected Performance
- Sign-in initiation: < 500ms
- Google OAuth flow: 2-5s
- Apple authentication: 2-5s
- Facebook login: 2-5s
- Token storage: < 100ms
- Sign-out: < 500ms

### Memory Usage
- Expected: ~100-150 MB
- Social auth SDKs: ~30-50 MB
- Firebase: ~20-30 MB
- Token storage: < 1 MB

## Module Architecture

```
lib/
├── social_auth/
│   ├── src/
│   │   ├── adapters/           # Provider implementations
│   │   │   ├── base_auth_adapter.dart
│   │   │   ├── google_auth_adapter.dart
│   │   │   ├── apple_auth_adapter.dart
│   │   │   └── facebook_auth_adapter.dart
│   │   ├── core/               # Core models
│   │   │   ├── social_provider.dart
│   │   │   ├── auth_result.dart
│   │   │   ├── social_auth_error.dart
│   │   │   ├── auth_service.dart
│   │   │   ├── token_storage.dart
│   │   │   └── logger.dart
│   │   ├── services/           # Service implementations
│   │   │   ├── social_auth_manager.dart
│   │   │   ├── firebase_auth_service.dart
│   │   │   └── rest_api_auth_service.dart
│   │   └── widgets/            # UI components
│   │       ├── social_sign_in_button.dart
│   │       └── social_sign_in_row.dart
│   └── social_auth.dart       # Main export
└── main.dart                   # Demo application
```

## Next Steps

1. **Configure Firebase** - Set up Firebase project and download config files
2. **Set Up Providers** - Configure OAuth for Google, Apple, Facebook
3. **Test on Devices** - Run on real iOS/Android devices
4. **Customize UI** - Adapt social auth buttons to your app theme
5. **Implement Backend** - Add server-side token verification
6. **Add Analytics** - Track sign-in success/failure rates
7. **Security Audit** - Review token storage and API usage
8. **Production Deploy** - Switch to production credentials

## Support & Resources

- **Google Sign-In:**
  - Package: https://pub.dev/packages/google_sign_in
  - Setup Guide: https://pub.dev/packages/google_sign_in#usage
  - Console: https://console.cloud.google.com

- **Apple Sign-In:**
  - Package: https://pub.dev/packages/sign_in_with_apple
  - Setup Guide: https://developer.apple.com/sign-in-with-apple/
  - Portal: https://developer.apple.com

- **Facebook Login:**
  - Package: https://pub.dev/packages/flutter_facebook_auth
  - Setup Guide: https://developers.facebook.com/docs/facebook-login
  - Console: https://developers.facebook.com

- **Firebase:**
  - Documentation: https://firebase.google.com/docs/auth
  - Console: https://console.firebase.google.com

---

**Status**: ✅ Ready for testing (with configuration)
**Last Updated**: November 16, 2025
**Flutter SDK**: 3.4.1+
**Dependencies**: All latest stable versions
