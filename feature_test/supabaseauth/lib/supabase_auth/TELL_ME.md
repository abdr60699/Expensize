# TELL ME - How to Test Supabase Authentication

This guide shows you what screens to create to test Supabase authentication features.

## Main File Setup

### Add Navigation Button in main.dart

```
Button: "Test Supabase Auth"
OnPressed: Navigate to SupabaseAuthTestScreen
```

## Screens to Create

### Screen 1: SupabaseAuthTestScreen (Main Menu)

**Purpose**: Navigation hub for all Supabase auth features

**UI Elements**:
```
AppBar: "Supabase Auth Testing"

If user is signed out:
  Buttons:
    "Email/Password Sign Up" → SignUpScreen
    "Email/Password Sign In" → SignInScreen
    "Magic Link Sign In" → MagicLinkScreen
    "Social Sign-In (Google)" → GoogleAuthScreen
    "Social Sign-In (GitHub)" → GitHubAuthScreen

If user is signed in:
  Text: "Signed in as: [email]"
  Text: "User ID: [uid]"
  Text: "Email verified: [Yes/No]"

  Buttons:
    "View Profile" → ProfileScreen
    "Update Profile" → UpdateProfileScreen
    "Change Password" → ChangePasswordScreen
    "Verify Email" → If not verified
    "Sign Out"
```

**What You Need to Do**:
- Open app
- See sign-in options (if signed out)
- Or see profile info (if signed in)

---

### Screen 2: SignUpScreen

**Purpose**: Create Supabase account with email/password

**UI Elements**:
```
AppBar: "Sign Up"

TextField: "Email"
TextField: "Password" (obscure, with toggle)
TextField: "Confirm Password"
TextField: "Full Name" (optional)

Checkbox: "I agree to Terms of Service"

Button: "Create Account"
TextButton: "Already have account? Sign In"

Text: Status messages
```

**What You Need to Do**:
1. Enter email: `test@example.com`
2. Enter password: `SecurePass123!`
3. Confirm password: `SecurePass123!`
4. Enter name: `Test User`
5. Check terms checkbox
6. Tap "Create Account"

**What You Should See**:
- Success: "Account created! Check email for verification link"
- Navigate to email verification prompt
- Check inbox for Supabase verification email
- Click link to verify

**Errors to Test**:
- Existing email: "Email already registered"
- Weak password: "Password must be at least 8 characters"
- Passwords don't match: "Passwords do not match"
- Invalid email: "Invalid email format"

**Implementation**:
```
Call: supabase.auth.signUp(
  email: email,
  password: password,
  data: {'full_name': name}
)

On success:
  - User created
  - Verification email sent
  - Show verification prompt

On error:
  - Map error to friendly message
  - Show to user
```

---

### Screen 3: SignInScreen

**Purpose**: Sign in with email/password

**UI Elements**:
```
AppBar: "Sign In"

TextField: "Email"
TextField: "Password"

Button: "Sign In"
TextButton: "Forgot Password?"
TextButton: "Don't have account? Sign Up"

Text: Status messages
```

**What You Need to Do**:
1. Enter email: `test@example.com`
2. Enter password: `SecurePass123!`
3. Tap "Sign In"

**What You Should See**:
- Success: Navigate to home/profile
- Session automatically saved
- User data accessible

**Errors to Test**:
- Wrong password: "Invalid login credentials"
- Non-existent email: "Invalid login credentials"
- Empty fields: "Email and password required"

**Session Persistence**:
1. Sign in successfully
2. Close app
3. Reopen app
4. Should still be signed in ✓

**Implementation**:
```
Call: supabase.auth.signInWithPassword(
  email: email,
  password: password
)

On success:
  - User signed in
  - Session saved automatically
  - Navigate to home

On error:
  - Show error message
```

---

### Screen 4: MagicLinkScreen

**Purpose**: Passwordless sign-in via email link

**UI Elements**:
```
AppBar: "Magic Link Sign In"

TextField: "Email"
Button: "Send Magic Link"

After sending:
  Text: "Magic link sent to [email]"
  Text: "Check your inbox and click the link to sign in"
  Text: "You can close this screen"

Text: Status messages
```

**What You Need to Do**:
1. Enter email: `test@example.com`
2. Tap "Send Magic Link"
3. Check email inbox
4. Click magic link in email
5. Browser opens → redirects to app
6. You're signed in!

**What You Should See**:
- "Magic link sent" message
- Email arrives with "Sign in to [App Name]" link
- Clicking link opens app
- Automatically signed in
- Navigate to home/profile

**Deep Link Handling**:
- App must handle deep links
- URL scheme configured (e.g., `myapp://`)
- Redirect URL in Supabase dashboard matches

**Implementation**:
```
Send magic link:
  supabase.auth.signInWithOtp(
    email: email,
    emailRedirectTo: 'myapp://auth-callback'
  )

Handle deep link:
  When app opens from link:
    Extract params from URL
    Session automatically restored
    Navigate to home
```

---

### Screen 5: GoogleAuthScreen

**Purpose**: Sign in with Google (OAuth)

**UI Elements**:
```
AppBar: "Google Sign In"

Button: "Sign in with Google"
  (White button with Google logo)

Text: Status messages
```

**What You Need to Do**:
1. Tap "Sign in with Google"
2. Google consent screen appears
3. Select Google account
4. Approve permissions
5. Redirected back to app
6. Signed in with Google account

**What You Should See**:
- Google account picker
- After selecting: Signed in
- Email from Google account used
- Profile info available (name, photo)
- Session persists

**Setup Required**:
- Enable Google provider in Supabase dashboard
- Add OAuth redirect URL
- Configure Google OAuth client ID

**Implementation**:
```
Initiate Google sign-in:
  supabase.auth.signInWithOAuth(
    Provider.google,
    redirectTo: 'myapp://auth-callback'
  )

Handle redirect:
  App opens from OAuth callback
  Session automatically created
  Navigate to home
```

---

### Screen 6: ProfileScreen

**Purpose**: Display current user profile

**UI Elements**:
```
AppBar: "Profile"
  Actions: Edit button

CircleAvatar: Profile photo or initials

Text: "Name: [full_name]"
Text: "Email: [email]"
Text: "Email Verified: [Yes/No]"
Text: "User ID: [uid]"
Text: "Created: [timestamp]"

If email not verified:
  Button: "Verify Email"

Buttons:
  "Update Profile"
  "Change Password"
  "Sign Out"
```

**What You Need to Do**:
1. Sign in
2. Navigate to profile
3. See your info displayed

**What You Should See**:
- Your email address
- Your name (if provided during sign-up)
- Email verification status
- Unique user ID

**Send Verification**:
1. If not verified, tap "Verify Email"
2. Email sent
3. Check inbox
4. Click verification link
5. Refresh profile
6. Status updates to "Yes"

**Implementation**:
```
Get current user:
  final user = supabase.auth.currentUser

Display:
  Email: user?.email
  Name: user?.userMetadata?['full_name']
  Verified: user?.emailConfirmedAt != null
  ID: user?.id

Send verification:
  await supabase.auth.resend(
    type: OtpType.signup,
    email: user.email
  )
```

---

### Screen 7: UpdateProfileScreen

**Purpose**: Update user profile information

**UI Elements**:
```
AppBar: "Update Profile"

TextField: "Full Name"
  (Pre-filled with current name)

TextField: "Phone" (optional)
TextField: "Bio" (optional)

Button: "Update Profile"

Text: Status messages
```

**What You Need to Do**:
1. Navigate to this screen
2. Change name to: `Updated Name`
3. Add phone: `+1234567890`
4. Tap "Update Profile"

**What You Should See**:
- Success message
- Navigate back to profile
- Name updated in profile screen
- Changes persist after app restart

**Implementation**:
```
Update user metadata:
  await supabase.auth.updateUser(
    UserAttributes(
      data: {
        'full_name': name,
        'phone': phone,
        'bio': bio,
      }
    )
  )

On success:
  - Metadata updated
  - User object refreshed
  - Show success message
```

---

### Screen 8: ChangePasswordScreen

**Purpose**: Change user password

**UI Elements**:
```
AppBar: "Change Password"

TextField: "Current Password"
TextField: "New Password"
TextField: "Confirm New Password"

Password strength indicator

Button: "Change Password"

Text: Status messages
```

**What You Need to Do**:
1. Enter current password
2. Enter new password: `NewSecure456!`
3. Confirm new password
4. Tap "Change Password"

**What You Should See**:
- Success: "Password updated successfully"
- Sign out automatically (security)
- Sign in with new password works
- Old password doesn't work

**Re-authentication**:
- Supabase may require recent sign-in
- If session old, re-authenticate first
- Then allow password change

**Implementation**:
```
Update password:
  await supabase.auth.updateUser(
    UserAttributes(password: newPassword)
  )

On success:
  - Password updated
  - Sign out user (security best practice)
  - Navigate to sign-in screen
  - User must sign in with new password
```

---

### Screen 9: ForgotPasswordScreen

**Purpose**: Reset forgotten password

**UI Elements**:
```
AppBar: "Reset Password"

TextField: "Email"
Button: "Send Reset Link"

Text: Status messages
```

**What You Need to Do**:
1. Enter email: `test@example.com`
2. Tap "Send Reset Link"
3. Check email inbox
4. Click reset link
5. Browser opens with reset form
6. Enter new password
7. Confirm new password
8. Submit

**What You Should See**:
- "Reset link sent" message
- Email with "Reset your password" link
- Link opens password reset page
- After resetting: Can sign in with new password

**Implementation**:
```
Send reset link:
  await supabase.auth.resetPasswordForEmail(
    email,
    redirectTo: 'myapp://auth-callback'
  )

Always show success (security - don't reveal if email exists):
  "If this email exists, reset link has been sent"
```

---

## Testing Checklist

### Email/Password Auth
- [ ] Sign up creates account
- [ ] Verification email received
- [ ] Clicking verification link verifies email
- [ ] Sign in works with correct credentials
- [ ] Wrong password shows error
- [ ] Session persists after app restart
- [ ] Sign out clears session

### Magic Link
- [ ] Magic link email sent
- [ ] Clicking link signs in user
- [ ] Deep linking works
- [ ] Session created automatically

### Social Auth
- [ ] Google sign-in works
- [ ] OAuth flow completes
- [ ] Email from Google used
- [ ] Profile info retrieved
- [ ] Session persists

### Profile Management
- [ ] Current user info displays
- [ ] Can update name, phone, bio
- [ ] Changes persist
- [ ] Email verification works

### Password Management
- [ ] Can change password
- [ ] Old password required
- [ ] New password works after change
- [ ] Password reset email works
- [ ] Can sign in with reset password

### Session Management
- [ ] Session persists across restarts
- [ ] Auth state stream updates
- [ ] Sign out clears session completely
- [ ] Expired session handled

---

## Quick Test Script

**5-Minute Email Auth Test**:
1. Open app → Supabase Auth Test
2. Tap "Sign Up"
3. Enter email, password, name
4. Tap "Create Account"
5. Check email → Click verify link ✓
6. Back to app → Tap "Sign In"
7. Enter credentials → Signed in ✓
8. Navigate to Profile → See your info ✓
9. Sign out → Back to sign-in screen ✓

**Magic Link Test**:
1. Tap "Magic Link Sign In"
2. Enter email
3. Tap "Send Link"
4. Check email → Click link ✓
5. App opens → Signed in ✓

**Social Auth Test** (if configured):
1. Tap "Google Sign In"
2. Google account picker appears
3. Select account → Approve ✓
4. Signed in with Google email ✓

---

## What to Expect

### Success Signs:
- ✓ Accounts created in Supabase dashboard (Authentication → Users)
- ✓ Verification emails received
- ✓ Sign-in works with correct credentials
- ✓ Session persists after restart
- ✓ Profile updates save correctly
- ✓ Password changes work
- ✓ Magic links sign in successfully
- ✓ Social OAuth completes

### Common Issues:
- **Verification email not received**: Check spam folder, check email in Supabase settings
- **Magic link doesn't work**: Check redirect URL configured, deep linking set up
- **Google auth fails**: Check OAuth client ID, redirect URL configured
- **Session doesn't persist**: Check Supabase client initialization
- **"Invalid login credentials"**: Wrong email/password, or email not verified (if required)

---

## Additional Features to Test

### Auth State Listener:
```
Implement stream listener:
  supabase.auth.onAuthStateChange.listen((data) {
    final session = data.session;
    if (session != null) {
      // User signed in
      Navigate to home
    } else {
      // User signed out
      Navigate to sign in
    }
  })
```

### Email Confirmation Required:
```
If Supabase project requires email confirmation:
  - Sign up → Email not verified
  - Try accessing protected routes → Blocked
  - Verify email → Access granted
```

### Row Level Security (RLS):
```
If using Supabase database with RLS:
  - Sign in → Can access own data
  - Sign out → Access denied
  - Sign in as different user → See different data
```

---

## Monitoring

**Supabase Dashboard - Authentication**:
- See all users
- User count
- Recent sign-ins
- Email verification status

**In App**:
- Current user ID
- Email verification status
- Session expiry time
- Auth state (signed in/out)

---

That's it! Build these screens and test all Supabase authentication flows end-to-end.
