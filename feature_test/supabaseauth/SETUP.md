# Setup Guide

Complete setup instructions for Supabase authentication from scratch.

## Supabase Project Setup

### 1. Create Supabase Project

1. Go to [https://supabase.com](https://supabase.com)
2. Sign up or log in
3. Click "New Project"
4. Enter project details:
   - Name
   - Database password
   - Region (choose closest to users)
5. Wait for project creation (~2 minutes)

### 2. Get API Credentials

1. Go to Project Settings → API
2. Copy:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **Anon/Public Key**: `eyJhbGc...` (public, safe for client)
   - **Service Role Key**: `eyJhbGc...` (secret, server-only!)

### 3. Configure Auth Providers

#### Email/Password

1. Authentication → Settings → Auth Providers
2. Email Provider → Enable
3. Configure:
   - ✅ Enable email confirmations (recommended)
   - Set confirmation redirect URL
   - Customize email templates (optional)

#### Magic Link

1. Authentication → Email Templates
2. Magic Link template → Customize (optional)
3. Set redirect URL

#### OAuth Providers

**Google:**
1. Create OAuth credentials in Google Cloud Console
2. Supabase → Authentication → Providers → Google
3. Enable and add:
   - Client ID
   - Client Secret
4. Add redirect URL to Google Console:
   - `https://xxxxx.supabase.co/auth/v1/callback`

**Apple:**
1. Create Services ID in Apple Developer
2. Supabase → Providers → Apple
3. Enable and configure Services ID
4. Add redirect URL

**GitHub:**
1. Create OAuth App in GitHub Settings
2. Supabase → Providers → GitHub  
3. Enable and add Client ID/Secret
4. Set callback URL

## Module Installation

### 1. Dependencies

```yaml
dependencies:
  supabase_flutter: ^2.10.3
  flutter_secure_storage: ^9.2.4
```

```bash
flutter pub get
```

### 2. Copy Module

```bash
cp -r feature_test/supabaseauth/lib/supabase_auth /path/to/your/project/lib/
```

### 3. Platform Setup

#### iOS (Info.plist)

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>myapp</string>
    </array>
  </dict>
</array>
```

#### Android (AndroidManifest.xml)

```xml
<activity android:name=".MainActivity">
  <intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="myapp" android:host="auth-callback" />
  </intent-filter>
</activity>
```

## Initialization

```dart
import 'package:supabaseauth/supabase_auth/supabase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = SupabaseAuthConfig(
    supabaseUrl: const String.fromEnvironment('SUPABASE_URL'),
    supabaseAnonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
    redirectUrl: 'myapp://auth-callback',
    useSecureStorageForSession: true,
  );

  final authService = SupabaseAuthService(
    config: config,
    tokenStorage: SecureTokenStorage(),
  );
  
  await authService.initialize();

  runApp(MyApp());
}
```

Run with:
```bash
flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJ...
```

## Testing

### Test Email Auth

```dart
Future<void> testEmailAuth() async {
  print('=== Testing Email Auth ===');

  final authRepo = AuthRepository(authService: authService);

  // Sign up
  final result = await authRepo.signUpWithEmail(
    email: 'test@example.com',
    password: 'Test123!',
  );

  print('✅ Sign-up: ${result.user?.email}');

  // Sign in
  final session = await authRepo.signInWithEmail(
    email: 'test@example.com',
    password: 'Test123!',
  );

  print('✅ Sign-in: ${session.user.email}');
  print('   Token: ${session.accessToken}');
}
```

### Test OAuth

```dart
Future<void> testOAuth() async {
  final result = await authRepo.signInWithOAuth(SocialProvider.google);

  if (result.user != null) {
    print('✅ OAuth sign-in: ${result.user!.email}');
  }
}
```

## Troubleshooting

### ❌ "Invalid API key"

**Cause:** Wrong anon key or URL.

**Fix:** Verify credentials in Supabase dashboard.

---

### ❌ "Email not confirmed"

**Cause:** Email verification required.

**Fix:** Check email or disable confirmations in Supabase settings.

---

### ❌ "OAuth callback failed"

**Cause:** Redirect URL not configured.

**Fix:** Add redirect URL to OAuth provider settings.

---

## Production Checklist

- [ ] Use environment variables for credentials
- [ ] Enable email confirmations
- [ ] Configure custom email templates
- [ ] Enable RLS policies
- [ ] Set up rate limiting
- [ ] Configure password requirements
- [ ] Test all auth flows
- [ ] Monitor auth logs
- [ ] Setup backup admin access

**Setup complete! Ready for production!**
