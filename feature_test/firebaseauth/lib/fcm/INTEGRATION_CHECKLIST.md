# FCM Integration Checklist

Complete checklist for integrating Firebase Cloud Messaging into your Flutter app.

## ✅ Pre-Integration

- [ ] Have a Firebase account
- [ ] Created Firebase project
- [ ] Have Android package name ready
- [ ] Have iOS bundle ID ready
- [ ] Physical devices available for testing (iOS notifications don't work reliably on simulator)

## ✅ Firebase Console Setup

### Create Project

- [ ] Logged into [Firebase Console](https://console.firebase.google.com/)
- [ ] Created new project or selected existing
- [ ] Enabled Google Analytics (recommended)
- [ ] Project is in Blaze (pay-as-you-go) plan if needed for high volume

### Add Android App

- [ ] Clicked "Add app" → Android
- [ ] Entered Android package name (from `android/app/build.gradle`)
- [ ] Downloaded `google-services.json`
- [ ] Placed `google-services.json` in `android/app/` directory
- [ ] Verified SHA-1 certificate fingerprint added (for debugging)
- [ ] Verified SHA-256 certificate fingerprint added (for production)

### Add iOS App

- [ ] Clicked "Add app" → iOS
- [ ] Entered iOS bundle ID (from Xcode)
- [ ] Downloaded `GoogleService-Info.plist`
- [ ] Added `GoogleService-Info.plist` to Xcode project (Runner folder)
- [ ] Verified bundle ID matches exactly

### Upload APNs Certificate/Key (iOS)

- [ ] Created APNs certificate in Apple Developer Portal OR
- [ ] Created APNs Auth Key (recommended)
- [ ] Uploaded certificate/key to Firebase Console
- [ ] Verified upload was successful
- [ ] Noted Key ID and Team ID (if using Auth Key)

## ✅ Module Installation

- [ ] Added `fcm_notifications` to `pubspec.yaml`
- [ ] Ran `flutter pub get`
- [ ] No dependency conflicts

## ✅ Android Configuration

### Build Configuration

- [ ] Updated `android/build.gradle`:
  - [ ] Added `com.google.gms:google-services` classpath
- [ ] Updated `android/app/build.gradle`:
  - [ ] Applied `com.google.gms.google-services` plugin
  - [ ] Set `minSdkVersion` to 21 or higher
  - [ ] Added Firebase BOM dependency
- [ ] Placed `google-services.json` in `android/app/`
- [ ] Verified package name matches across all files

### Manifest Configuration

- [ ] Opened `android/app/src/main/AndroidManifest.xml`
- [ ] Added notification icon metadata
- [ ] Added notification color metadata
- [ ] Added default channel metadata
- [ ] Added internet permission (should already exist)

### Notification Icon

- [ ] Created `ic_notification.xml` in `res/drawable/`
- [ ] Icon is pure white (transparent background)
- [ ] Icon is simple and recognizable at small sizes
- [ ] Tested icon appearance

### Colors

- [ ] Created `res/values/colors.xml` if doesn't exist
- [ ] Added notification color
- [ ] Color matches app branding

### Test Build

- [ ] Ran `flutter clean`
- [ ] Ran `flutter build apk --debug`
- [ ] Build succeeded without errors
- [ ] No Google Services plugin errors

## ✅ iOS Configuration

### Xcode Setup

- [ ] Opened `ios/Runner.xcworkspace` in Xcode (NOT .xcodeproj)
- [ ] Selected Runner target
- [ ] Went to "Signing & Capabilities"
- [ ] Added "Push Notifications" capability
- [ ] Added "Background Modes" capability
- [ ] Checked "Remote notifications" under Background Modes
- [ ] Verified `GoogleService-Info.plist` is in Runner folder
- [ ] Verified bundle ID matches Firebase

### AppDelegate Configuration

- [ ] Opened `ios/Runner/AppDelegate.swift`
- [ ] Added Firebase import
- [ ] Added `Firebase.configure()` in `didFinishLaunchingWithOptions`
- [ ] Added notification permission request code
- [ ] Added `registerForRemoteNotifications()` call
- [ ] Implemented `didRegisterForRemoteNotificationsWithDeviceToken`

### Info.plist Configuration

- [ ] Opened `ios/Runner/Info.plist`
- [ ] Added `FirebaseAppDelegateProxyEnabled` set to `false`
- [ ] Saved changes

### Test Build

- [ ] Ran `flutter clean`
- [ ] Ran `flutter build ios --debug`
- [ ] Build succeeded without errors
- [ ] No Firebase configuration errors

## ✅ Code Integration

### Initialization

- [ ] Imported `fcm_notifications` package
- [ ] Added `WidgetsFlutterBinding.ensureInitialized()` in `main()`
- [ ] Called `FCMService.initialize()` before `runApp()`
- [ ] Configured `FCMConfig` (production or development)
- [ ] App starts without errors

### Notification Listener

- [ ] Set up notification stream listener
- [ ] Implemented `onNotificationReceived` handler
- [ ] Tested with print statements
- [ ] Verified notifications are received

### Token Listener

- [ ] Set up token stream listener
- [ ] Logged token to console
- [ ] Implemented `sendTokenToServer` function
- [ ] Token is being sent to backend

### Background Message Handler

- [ ] Created top-level background message handler function
- [ ] Added `@pragma('vm:entry-point')` annotation
- [ ] Registered handler with `FirebaseMessaging.onBackgroundMessage`
- [ ] Background handler doesn't show UI
- [ ] Background handler completes quickly

### Permission Request (iOS)

- [ ] Called `requestPermission()` at appropriate time
- [ ] Showed explanation before requesting
- [ ] Handled permission granted
- [ ] Handled permission denied
- [ ] Provided way to open settings if denied

## ✅ Backend Integration

### Token Storage

- [ ] Created API endpoint to receive FCM tokens
- [ ] Endpoint accepts POST with token
- [ ] Token is stored in database
- [ ] Token is associated with user/device
- [ ] Endpoint validates token format
- [ ] Endpoint handles duplicates

### Token Update

- [ ] App sends token on first launch
- [ ] App sends token after login
- [ ] App sends token on refresh
- [ ] App removes token on logout
- [ ] Backend handles token updates

### Send Notification API

- [ ] Created API endpoint to send notifications
- [ ] Endpoint uses Firebase Admin SDK
- [ ] Endpoint validates recipient
- [ ] Endpoint handles errors
- [ ] Endpoint returns success/failure
- [ ] Endpoint logs notification sends

### Server Configuration

- [ ] Downloaded service account JSON from Firebase Console
- [ ] Stored service account file securely
- [ ] Set environment variable for service account path
- [ ] Initialized Firebase Admin SDK
- [ ] Tested sending notification from server

## ✅ Testing

### Android Testing

#### Foreground

- [ ] App running and visible
- [ ] Sent test notification from Firebase Console
- [ ] Notification appeared as local notification
- [ ] Notification has correct title and body
- [ ] Notification icon is correct
- [ ] Notification color is correct
- [ ] Tapped notification
- [ ] App handled tap correctly

#### Background

- [ ] App in background (home button pressed)
- [ ] Sent test notification
- [ ] Notification appeared in status bar
- [ ] Notification sound played
- [ ] Tapped notification
- [ ] App opened and handled notification

#### Terminated

- [ ] App completely closed (swiped away)
- [ ] Sent test notification
- [ ] Notification appeared in status bar
- [ ] Tapped notification
- [ ] App launched and handled notification

### iOS Testing

#### Foreground

- [ ] App running on physical device
- [ ] Sent test notification from Firebase Console
- [ ] Notification appeared as banner
- [ ] Notification has correct title and body
- [ ] Tapped notification
- [ ] App handled tap correctly

#### Background

- [ ] App in background (home button pressed)
- [ ] Sent test notification
- [ ] Notification appeared as banner
- [ ] Notification sound played
- [ ] Tapped notification
- [ ] App opened and handled notification

#### Terminated

- [ ] App completely closed (swiped away)
- [ ] Sent test notification
- [ ] Notification appeared
- [ ] Tapped notification
- [ ] App launched and handled notification

### Permission Testing (iOS)

- [ ] First launch shows permission dialog
- [ ] "Allow" grants permission
- [ ] "Don't Allow" denies permission
- [ ] Denied permission handled gracefully
- [ ] App provides way to open Settings
- [ ] Permission status persists after app restart

### Topic Testing

- [ ] Subscribed to test topic
- [ ] Sent notification to topic
- [ ] Notification received
- [ ] Unsubscribed from topic
- [ ] Sent notification to topic
- [ ] Notification NOT received

### Deep Linking

- [ ] Notification includes click_action
- [ ] Tapped notification
- [ ] App navigated to correct screen
- [ ] Deep link parameters parsed correctly
- [ ] Deep link works from all states (foreground/background/terminated)

### Data Payload

- [ ] Sent notification with custom data
- [ ] Data received in notification object
- [ ] Data parsed correctly
- [ ] Data used to show relevant content

## ✅ Production Preparation

### Security

- [ ] Server key not in client code
- [ ] Service account JSON not in repository
- [ ] Tokens sent over HTTPS only
- [ ] Sensitive data not in notifications
- [ ] Backend validates notification requests

### Error Handling

- [ ] FCM initialization errors caught
- [ ] Permission denial handled gracefully
- [ ] Network errors handled
- [ ] Invalid tokens handled on backend
- [ ] Failed sends are retried or logged

### Analytics

- [ ] Notification delivery tracked
- [ ] Notification opens tracked
- [ ] User engagement measured
- [ ] A/B testing set up (optional)

### Performance

- [ ] Background handler completes quickly
- [ ] No memory leaks from listeners
- [ ] Token refresh handled efficiently
- [ ] Notification display is smooth

### User Experience

- [ ] Permission requested at right time
- [ ] Permission purpose explained
- [ ] Notifications are relevant
- [ ] Notification frequency is reasonable
- [ ] Users can opt-out easily

## ✅ Documentation

- [ ] Documented FCM setup for team
- [ ] Created notification sending guide
- [ ] Documented deep link format
- [ ] Created troubleshooting guide
- [ ] Documented topic naming convention

## ✅ Monitoring

- [ ] Set up Firebase Cloud Messaging metrics
- [ ] Monitor delivery rates
- [ ] Monitor open rates
- [ ] Set up alerts for errors
- [ ] Review analytics regularly

## ✅ Compliance

- [ ] User can opt-out of notifications
- [ ] Privacy policy mentions notifications
- [ ] GDPR compliance checked (EU users)
- [ ] App Store requirements met
- [ ] Play Store requirements met

## 🚨 Common Issues Checklist

If notifications not working, verify:

### Android

- [ ] `google-services.json` is in correct location
- [ ] Package name matches Firebase Console
- [ ] Google Services plugin applied
- [ ] Notification channel created (Android 8+)
- [ ] App has notification permission (Android 13+)
- [ ] Device is not in Do Not Disturb mode
- [ ] Battery optimization disabled for app

### iOS

- [ ] `GoogleService-Info.plist` in Xcode project
- [ ] Bundle ID matches Firebase Console
- [ ] Push Notifications capability enabled
- [ ] Background Modes enabled with Remote notifications
- [ ] APNs certificate/key uploaded to Firebase
- [ ] Testing on physical device (not simulator)
- [ ] Notification permission granted
- [ ] Device is not in Do Not Disturb mode

### Both Platforms

- [ ] Firebase project configured correctly
- [ ] Internet connection available
- [ ] FCM service initialized
- [ ] Token obtained successfully
- [ ] Server key is correct (for server-side sends)
- [ ] Message format is valid
- [ ] No typos in topic names

## ✅ Final Verification

- [ ] Tested on Android device
- [ ] Tested on iOS device
- [ ] Tested all notification states
- [ ] Tested with real backend
- [ ] Tested topic subscriptions
- [ ] Tested deep linking
- [ ] Performance is acceptable
- [ ] No crashes or errors
- [ ] Team trained on sending notifications
- [ ] Documentation complete

## 🎉 Integration Complete!

Once all items are checked:

- [ ] Committed all changes
- [ ] Created pull request
- [ ] Code reviewed
- [ ] Tested in staging
- [ ] Ready for production

---

**Need Help?**
- Review the [Main README](README.md)
- Check [Firebase Documentation](https://firebase.google.com/docs/cloud-messaging)
- Review platform-specific setup sections
- Check Firebase Console for errors
