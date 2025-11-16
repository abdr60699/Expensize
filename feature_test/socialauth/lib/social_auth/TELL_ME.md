# TELL ME - How to Test Social Authentication

This guide shows you what screens to create to test social sign-in (Google, Apple, Facebook).

## Main File Setup

### Add Navigation Button in main.dart

```
Button: "Test Social Auth"
OnPressed: Navigate to SocialAuthTestScreen
```

## Screens to Create

### Screen 1: SocialAuthTestScreen (Main Menu)

**Purpose**: Test all social authentication providers

**UI Elements**:
```
AppBar: "Social Auth Testing"

If signed out:
  Buttons (with provider logos):
    "Sign in with Google"
    "Sign in with Apple"
    "Sign in with Facebook"

  Text: "Or test individual features:"
  Buttons:
    "Google Only" → GoogleTestScreen
    "Apple Only" → AppleTestScreen
    "Facebook Only" → FacebookTestScreen

If signed in:
  CircleAvatar: Profile photo from provider
  Text: "Signed in with: [Google/Apple/Facebook]"
  Text: "Name: [display name]"
  Text: "Email: [email]"
  Text: "User ID: [uid]"

  Buttons:
    "View Full Profile" → ProfileScreen
    "Link Another Provider" → LinkProvidersScreen
    "Sign Out"
```

**What You Need to Do**:
- Open app
- See social sign-in buttons
- Tap any provider to sign in

---

### Screen 2: GoogleTestScreen

**Purpose**: Test Google Sign-In

**UI Elements**:
```
AppBar: "Google Sign-In Test"

Button: "Sign in with Google"
  (White background, Google logo, "Sign in with Google" text)

After sign-in:
  Text: "Sign-in successful!"
  Text: "Name: [name from Google]"
  Text: "Email: [email from Google]"
  Text: "Photo URL: [photo URL]"
  Image: Profile photo
  Text: "Access Token: [token]"
  Text: "ID Token: [ID token]"

  Button: "Sign Out from Google"

Text area: Shows status/errors
```

**What You Need to Do**:
1. Tap "Sign in with Google"
2. Google account picker appears
3. Select a Google account
4. Approve permissions (first time only)

**What You Should See**:
- Google account picker with your accounts
- After selecting:
  - Your Google name displayed
  - Your Google email displayed
  - Your Google profile photo shown
  - Access token received (long string)
  - ID token received

**Android Specific**:
- Ensure SHA-1 fingerprint added to Firebase/Google Cloud Console
- google-services.json in android/app/

**iOS Specific**:
- GoogleService-Info.plist in project
- URL scheme configured
- OAuth client ID for iOS configured

**Web**:
- OAuth client ID for web configured
- Authorized JavaScript origins added

**Implementation**:
```
On button press:
  1. Initialize GoogleSignIn
  2. Call: googleSignIn.signIn()
  3. If successful:
     - Get GoogleSignInAccount
     - Extract: displayName, email, photoUrl
     - Get authentication:
       - accessToken
       - idToken
     - Display all info
  4. If cancelled:
     - User cancelled: Show "Sign-in cancelled"
  5. If error:
     - Show error message
```

**Testing Scenarios**:
- [ ] Sign in with account A → Success
- [ ] Sign out
- [ ] Sign in with account B → Success
- [ ] Sign in again → No picker (cached)
- [ ] Clear cache → Picker appears again

---

### Screen 3: AppleTestScreen

**Purpose**: Test Sign in with Apple

**UI Elements**:
```
AppBar: "Apple Sign-In Test"

Button: "Sign in with Apple"
  (Black background, white Apple logo)

After sign-in:
  Text: "Apple sign-in successful!"
  Text: "Name: [name or null]"
  Text: "Email: [email or privaterelay@apple.com]"
  Text: "User ID: [Apple user identifier]"
  Text: "Identity Token: [token]"
  Text: "Authorization Code: [code]"

  Text: "Note: Name only provided on first sign-in"

  Button: "Sign Out"

Text area: Status messages
```

**What You Need to Do** (iOS):
1. Tap "Sign in with Apple"
2. Face ID/Touch ID prompt appears
3. Authenticate with biometric
4. Choose to share or hide email
5. Approve

**What You Should See** (iOS):
- Biometric authentication prompt
- Email sharing options:
  - Share My Email
  - Hide My Email (generates @privaterelay.apple.com)
- After approval:
  - Your name (first time only)
  - Email (real or relay)
  - User identifier
  - Identity token

**Android/Web**:
- Web-based Apple sign-in flow
- Opens browser for authentication
- Redirects back to app

**Setup Required**:
- Apple Developer account
- App ID with "Sign in with Apple" capability
- Service ID configured
- Key for Sign in with Apple created
- iOS: Capability enabled in Xcode

**Implementation**:
```
On button press:
  1. Check if available (iOS 13+ or web)
  2. Call: SignInWithApple.getAppleIDCredential()
  3. Parameters:
     - Requested scopes: [email, fullName]
  4. If successful:
     - Get credential:
       - userIdentifier
       - email
       - givenName, familyName (first time only)
       - identityToken
       - authorizationCode
     - Display info
  5. If cancelled:
     - Show "Sign-in cancelled"
  6. If error:
     - Show error message
```

**Important Notes**:
- Name provided only on FIRST sign-in
- Subsequent sign-ins: Name will be null
- Save name on first sign-in if needed
- Email may be privaterelay (if user chose to hide)

**Testing with Sandbox**:
- Use sandbox Apple ID for testing
- Create sandbox account in App Store Connect
- Sign in with sandbox account on device

---

### Screen 4: FacebookTestScreen

**Purpose**: Test Facebook Login

**UI Elements**:
```
AppBar: "Facebook Login Test"

Button: "Continue with Facebook"
  (Blue background, white Facebook logo)

After login:
  Text: "Facebook login successful!"
  Text: "Name: [name from Facebook]"
  Text: "Email: [email]"
  Text: "User ID: [Facebook user ID]"
  Image: Profile photo
  Text: "Access Token: [token]"

  Button: "Fetch More Info" → Gets additional profile data
  Button: "Log Out from Facebook"

Text area: Status messages
```

**What You Need to Do**:
1. Tap "Continue with Facebook"
2. Facebook login screen appears
3. Enter Facebook email/password (or use saved session)
4. Approve app permissions
5. Redirected back to app

**What You Should See**:
- Facebook login screen (web view or app)
- Permission request screen (first time)
- After approval:
  - Your Facebook name
  - Your Facebook email
  - Your Facebook profile photo
  - User ID
  - Access token

**Setup Required**:
- Facebook Developer account
- Create Facebook App
- Get App ID and App Secret
- Configure OAuth redirect URIs
- Add app to Facebook App Review (for production)

**Android**:
- Add Facebook App ID to strings.xml
- Add FacebookActivity to AndroidManifest.xml
- Add key hash to Facebook app settings

**iOS**:
- Add Facebook App ID to Info.plist
- Configure URL scheme
- Add required permissions

**Implementation**:
```
On button press:
  1. Initialize FacebookAuth
  2. Call: FacebookAuth.instance.login()
  3. Permissions: ['email', 'public_profile']
  4. If successful:
     - Get LoginResult
     - Access token: result.accessToken
     - User ID: result.accessToken.userId
  5. Get profile:
     - Call Graph API: /me?fields=name,email,picture
     - Parse response
     - Display info
  6. If cancelled:
     - Show "Login cancelled"
  7. If error:
     - Show error message
```

**Fetch Additional Data**:
```
After login, get more profile info:
  FacebookAuth.instance.getUserData(
    fields: "name,email,picture.width(200),birthday,friends"
  )

Display additional fields:
  - Birthday (if permission granted)
  - Friends list
  - Larger profile photo
```

---

### Screen 5: ProfileScreen

**Purpose**: Display full profile info from provider

**UI Elements**:
```
AppBar: "Social Profile"

CircleAvatar: Large profile photo (200x200)

Card:
  Text: "Provider: [Google/Apple/Facebook]"
  Text: "Name: [full name]"
  Text: "Email: [email]"
  Text: "User ID: [provider user ID]"
  Text: "Photo URL: [url]"

Card:
  Text: "Token Information:"
  Text: "Access Token: [token...]" (truncated)
  Text: "Token Expiry: [expiry time]"
  Button: "Copy Full Token"

Card:
  Text: "Additional Data:"
  (Display any extra data from provider)

Buttons:
  "Refresh Profile"
  "Link Another Provider"
  "Sign Out"
```

**What You Need to Do**:
1. Sign in with any provider
2. Navigate to this screen

**What You Should See**:
- All profile information displayed
- Profile photo loaded from URL
- Token information shown
- Can copy token for testing

---

### Screen 6: LinkProvidersScreen

**Purpose**: Link multiple social providers to one account

**UI Elements**:
```
AppBar: "Link Accounts"

Section: Currently Linked
  Chip: "Google" (if linked)
  Chip: "Apple" (if linked)
  Chip: "Facebook" (if linked)

Section: Available to Link
  Button: "Link Google" (if not linked)
  Button: "Link Apple" (if not linked)
  Button: "Link Facebook" (if not linked)

Section: Unlink
  Text: "Tap a chip above to unlink"
  Warning: "Must keep at least one provider linked"

Text area: Status messages
```

**What You Need to Do**:
1. Sign in with Google
2. Navigate to this screen
3. Tap "Link Apple"
4. Complete Apple sign-in
5. Now linked to both

**What You Should See**:
- After linking: Both Google and Apple chips shown
- Can sign in with either provider
- Both access same account/data

**To Unlink**:
1. Tap on "Apple" chip
2. Confirm unlink
3. Apple removed
4. Can no longer sign in with Apple
5. Google still works

---

## Testing Checklist

### Google Sign-In
- [ ] Sign in works (account picker appears)
- [ ] Name, email, photo retrieved
- [ ] Access token received
- [ ] Sign out clears session
- [ ] Can sign in again
- [ ] Silent sign-in works (cached)
- [ ] Works on Android (SHA-1 configured)
- [ ] Works on iOS (URL scheme configured)
- [ ] Works on Web (OAuth client configured)

### Apple Sign-In
- [ ] Sign in works (biometric prompt on iOS)
- [ ] Email sharing options shown
- [ ] Name received on first sign-in
- [ ] User identifier received
- [ ] Identity token received
- [ ] Works with real Apple ID
- [ ] Works with privaterelay email
- [ ] Sign out works
- [ ] Web flow works (Android/Web)

### Facebook Login
- [ ] Login screen appears
- [ ] Can authenticate with Facebook account
- [ ] Name, email retrieved
- [ ] Profile photo retrieved
- [ ] Access token received
- [ ] Can fetch additional profile data
- [ ] Log out works
- [ ] Works on Android (key hash configured)
- [ ] Works on iOS (URL scheme configured)

### Provider Linking
- [ ] Can link Google to Apple account
- [ ] Can link Facebook to existing account
- [ ] Can sign in with any linked provider
- [ ] Can unlink provider
- [ ] Cannot unlink last provider
- [ ] Linked providers persist

### Error Handling
- [ ] Cancelled sign-in handled gracefully
- [ ] Network error handled
- [ ] Invalid configuration shows error
- [ ] Missing SDK shows error
- [ ] Permission denied handled

---

## Quick Test Script

**5-Minute Google Test**:
1. Open app → Social Auth Test
2. Tap "Sign in with Google"
3. Google picker appears ✓
4. Select account → Signed in ✓
5. See name, email, photo ✓
6. Tap "Sign Out"
7. Sign in again → Works ✓

**Apple Test** (iOS):
1. Tap "Sign in with Apple"
2. FaceID prompt ✓
3. Approve → Signed in ✓
4. Choose "Hide My Email"
5. See privaterelay email ✓

**Facebook Test**:
1. Tap "Continue with Facebook"
2. Facebook login ✓
3. Approve permissions ✓
4. See profile info ✓

**Linking Test**:
1. Sign in with Google
2. Go to "Link Accounts"
3. Tap "Link Apple"
4. Complete Apple sign-in ✓
5. Both chips shown ✓
6. Sign out
7. Sign in with Apple → Works ✓
8. Same account accessed ✓

---

## What to Expect

### Success Signs:
- ✓ Provider-specific login screens appear
- ✓ Profile info retrieved (name, email, photo)
- ✓ Tokens received and valid
- ✓ Can sign out and sign in again
- ✓ Linking works across providers
- ✓ Session persists

### Common Issues:
- **Google: Error 10**: OAuth client not configured or SHA-1 missing
- **Google: Error 12500**: google-services.json not in project
- **Apple: Not available**: iOS version < 13 or capability not enabled
- **Apple: No name on 2nd sign-in**: Expected (name only on first sign-in)
- **Facebook: Login fails**: App ID/Secret incorrect or redirect URI wrong
- **All: Network error**: Check internet connection

---

## Platform-Specific Notes

### Android
- **Google**: Requires SHA-1 and SHA-256 fingerprints
- **Apple**: Web-based flow (opens browser)
- **Facebook**: Requires key hash in Facebook dashboard

### iOS
- **Google**: Requires URL scheme and client ID
- **Apple**: Native flow with biometrics
- **Facebook**: Requires URL scheme and Info.plist config

### Web
- **Google**: OAuth client ID for web
- **Apple**: Web-based flow with Service ID
- **Facebook**: JavaScript SDK with App ID

---

That's it! Build these screens to test all social authentication providers end-to-end.
