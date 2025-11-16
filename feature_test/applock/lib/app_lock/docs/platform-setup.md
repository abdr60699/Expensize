# Platform Setup Guide

## iOS Setup

### 1. Add Face ID/Touch ID Usage Description

Edit `ios/Runner/Info.plist` and add:

```xml
<key>NSFaceIDUsageDescription</key>
<string>Unlock the app using Face ID or Touch ID</string>
```

### 2. Keychain Configuration

The package uses the iOS Keychain for secure storage. No additional configuration is needed, but you may want to configure keychain access groups if needed.

Add to `ios/Runner/Runner.entitlements` (create if doesn't exist):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>keychain-access-groups</key>
    <array>
        <string>$(AppIdentifierPrefix)com.yourcompany.yourapp</string>
    </array>
</dict>
</plist>
```

### 3. Minimum iOS Version

Ensure minimum iOS version is 11.0 or higher in `ios/Podfile`:

```ruby
platform :ios, '11.0'
```

### 4. Testing Biometrics on Simulator

- Hardware > Face ID > Enrolled
- Hardware > Touch ID > Enrolled

---

## Android Setup

### 1. Add Biometric Permission

Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.USE_BIOMETRIC"/>
    ...
</manifest>
```

### 2. Minimum SDK Version

Ensure minimum SDK is API 23 (Marshmallow) in `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        minSdkVersion 23
        ...
    }
}
```

### 3. AndroidX Migration

Ensure AndroidX is enabled in `android/gradle.properties`:

```properties
android.useAndroidX=true
android.enableJetifier=true
```

### 4. ProGuard Rules (if using code obfuscation)

Add to `android/app/proguard-rules.pro`:

```pro
# Flutter Secure Storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Local Auth
-keep class io.flutter.plugins.localauth.** { *; }
```

### 5. Testing Biometrics on Emulator

AVD must have fingerprint or face authentication enabled:
1. Settings > Security > Screen lock > Pattern/PIN
2. Settings > Security > Fingerprint (or Face unlock)

Note: Biometric authentication may not work reliably on some emulators. Test on real devices for production.

---

## Common Issues

### iOS: "User denied biometric authentication"

Make sure:
1. NSFaceIDUsageDescription is in Info.plist
2. User has enrolled Face ID/Touch ID on device
3. App has permission to use biometrics

### Android: "Biometric hardware not available"

Check:
1. Device runs Android 6.0+ (API 23+)
2. Device has biometric sensor
3. User has enrolled biometrics
4. Correct permissions in AndroidManifest.xml

### Secure Storage Not Working

iOS:
- Check Keychain configuration
- Ensure app is code-signed properly
- Check device storage is not full

Android:
- Ensure minSdkVersion >= 23
- Check AndroidX is enabled
- Verify encrypted shared preferences setup

---

## Production Checklist

- [ ] iOS: NSFaceIDUsageDescription added
- [ ] Android: USE_BIOMETRIC permission added
- [ ] Minimum SDK versions set correctly
- [ ] Tested biometrics on real devices
- [ ] Tested secure storage persistence
- [ ] Tested app lock on background/foreground
- [ ] Tested lockout behavior
- [ ] Verified PIN security (not stored in plain text)
- [ ] Tested on both iOS and Android
- [ ] Added error handling for biometric failures
