# UPI Payment Module - Complete Setup & Process Guide

**For**: Developers and Release Engineers
**Platform**: Android (UPI is India-specific)
**Version**: 1.0.0
**Last Updated**: 2025-11-14

This document provides complete step-by-step instructions for integrating the UPI Payment Module into any Flutter app.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Module Integration](#module-integration)
3. [Android Platform Setup](#android-platform-setup)
4. [Flutter Configuration](#flutter-configuration)
5. [Testing Setup](#testing-setup)
6. [Production Deployment](#production-deployment)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Development Environment
- ✅ Flutter SDK 3.4.1+ installed
- ✅ Android Studio / VS Code
- ✅ Android SDK 26+ (Android 8.0+)
- ✅ Physical Android device or emulator for testing

### Knowledge Required
- Basic Flutter development
- Understanding of Android intents
- Basic knowledge of UPI payments

### Accounts & Access
- Merchant UPI ID (VPA) for receiving payments
- Access to your app's backend server (for verification)
- Google Play Console access (for production)

---

## Module Integration

### Step 1: Copy Module to Project

The UPI Payment module is located at `/home/user/reusble_widgtes/lib/features/upi_payment/` in this repository.

**Option A: Use as-is** (if this is your project)
```bash
# Module is already in lib/features/upi_payment/
# Skip to Step 2
```

**Option B: Copy to another project**
```bash
# Copy entire upi_payment folder to your project
cp -r lib/features/upi_payment /path/to/your/project/lib/features/
```

### Step 2: Add Dependencies

Add to your `pubspec.yaml`:

```yaml
dependencies:
  # Core dependencies (likely already present)
  flutter:
    sdk: flutter

  # HTTP client (likely already present)
  http: ^1.1.0

  # Local storage (likely already present)
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # Secure storage (likely already present)
  flutter_secure_storage: ^9.0.0

  # UUID generation (add if not present)
  uuid: ^4.2.1

dev_dependencies:
  # Code generation
  build_runner: ^2.4.6
  hive_generator: ^2.0.1
```

Run:
```bash
flutter pub get
```

---

## Android Platform Setup

### Step 1: Create Method Channel Handler

Create file: `android/app/src/main/kotlin/com/yourcompany/yourapp/UpiMethodChannel.kt`

```kotlin
package com.yourcompany.yourapp

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

class UpiMethodChannel(
    private val activity: Activity
) : MethodChannel.MethodCallHandler, PluginRegistry.ActivityResultListener {

    companion object {
        private const val CHANNEL = "com.yourcompany.yourapp/upi"
        private const val REQUEST_CODE_UPI = 4789
    }

    private var pendingResult: MethodChannel.Result? = null
    private lateinit var channel: MethodChannel

    fun register(flutterEngine: FlutterEngine) {
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isAppInstalled" -> {
                val packageName = call.argument<String>("packageName") ?: ""
                result.success(isPackageInstalled(packageName))
            }
            "getInstalledApps" -> {
                val packageNames = call.argument<List<String>>("packageNames") ?: emptyList()
                val installed = packageNames.filter { isPackageInstalled(it) }
                result.success(installed)
            }
            "initiatePayment" -> {
                val upiUrl = call.argument<String>("upiUrl") ?: ""
                val packageName = call.argument<String>("packageName")

                if (upiUrl.isEmpty()) {
                    result.error("INVALID_URL", "UPI URL is required", null)
                    return
                }

                pendingResult = result
                launchUpiApp(upiUrl, packageName)
            }
            else -> result.notImplemented()
        }
    }

    private fun isPackageInstalled(packageName: String): Boolean {
        return try {
            activity.packageManager.getPackageInfo(packageName, 0)
            true
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
    }

    private fun launchUpiApp(upiUrl: String, packageName: String?) {
        try {
            val intent = Intent(Intent.ACTION_VIEW).apply {
                data = Uri.parse(upiUrl)
                packageName?.let { setPackage(it) }
            }

            activity.startActivityForResult(intent, REQUEST_CODE_UPI)
        } catch (e: Exception) {
            pendingResult?.error("LAUNCH_ERROR", "Failed to launch UPI app: ${e.message}", null)
            pendingResult = null
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == REQUEST_CODE_UPI) {
            if (data != null) {
                val response = parseUpiResponse(data)
                pendingResult?.success(response)
            } else {
                pendingResult?.error("USER_CANCELED", "User canceled the payment", null)
            }
            pendingResult = null
            return true
        }
        return false
    }

    private fun parseUpiResponse(data: Intent): Map<String, String?> {
        return mapOf(
            "Status" to data.getStringExtra("Status"),
            "txnId" to data.getStringExtra("txnId"),
            "txnRef" to data.getStringExtra("txnRef"),
            "ApprovalRefNo" to data.getStringExtra("ApprovalRefNo"),
            "responseCode" to data.getStringExtra("responseCode"),
            "errorMessage" to data.getStringExtra("errorMessage")
        )
    }
}
```

### Step 2: Register Method Channel

Edit: `android/app/src/main/kotlin/com/yourcompany/yourapp/MainActivity.kt`

```kotlin
package com.yourcompany.yourapp

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.PluginRegistry

class MainActivity: FlutterActivity() {
    private lateinit var upiMethodChannel: UpiMethodChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Register UPI method channel
        upiMethodChannel = UpiMethodChannel(this)
        upiMethodChannel.register(flutterEngine)

        // Register activity result listener
        flutterEngine
            .activityControlSurface
            .attachToActivity(this, lifecycle)

        addOnNewIntentListener { intent ->
            // Handle deep links if needed
            false
        }
    }

    private fun addOnNewIntentListener(listener: (android.content.Intent) -> Boolean) {
        // Implement if you need deep link handling
    }
}
```

### Step 3: Update AndroidManifest.xml

Edit: `android/app/src/main/AndroidManifest.xml`

Add queries for UPI apps (required for Android 11+):

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- Add internet permission if not present -->
    <uses-permission android:name="android.permission.INTERNET" />

    <!-- Add queries for UPI apps (Android 11+) -->
    <queries>
        <!-- Google Pay -->
        <package android:name="com.google.android.apps.nbu.paisa.user" />

        <!-- PhonePe -->
        <package android:name="com.phonepe.app" />

        <!-- BHIM -->
        <package android:name="in.org.npci.upiapp" />

        <!-- Paytm -->
        <package android:name="net.one97.paytm" />

        <!-- Amazon Pay -->
        <package android:name="in.amazon.mShop.android.shopping" />

        <!-- Generic UPI intent -->
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="upi" />
        </intent>
    </queries>

    <application
        android:label="Your App Name"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">

            <!-- Standard configuration -->
            <meta-data
                android:name="io.flutter.embedding.android.NormalTheme"
                android:resource="@style/NormalTheme" />

            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>

        <!-- Don't delete the meta-data below -->
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

### Step 4: Update build.gradle

Edit: `android/app/build.gradle`

Ensure minimum SDK is 26:

```gradle
android {
    compileSdkVersion 33

    defaultConfig {
        applicationId "com.yourcompany.yourapp"
        minSdkVersion 26  // Minimum for UPI
        targetSdkVersion 33
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }

    buildTypes {
        release {
            // ProGuard rules
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'

            signingConfig signingConfigs.release
        }
    }
}
```

### Step 5: Add ProGuard Rules

Create/edit: `android/app/proguard-rules.pro`

```proguard
# UPI Payment Module
-keep class com.yourcompany.yourapp.UpiMethodChannel { *; }
-keep class * extends io.flutter.plugin.common.MethodChannel { *; }

# Keep UPI intent data
-keepclassmembers class * {
    public <methods>;
}
```

---

## Flutter Configuration

### Step 1: Create Platform Channel Dart Interface

Create: `lib/features/upi_payment/platform/android/upi_method_channel.dart`

```dart
import 'dart:io';
import 'package:flutter/services.dart';
import '../../models/upi_models.dart';

class UpiMethodChannel {
  static const MethodChannel _channel =
      MethodChannel('com.yourcompany.yourapp/upi');

  /// Check if UPI app is installed
  static Future<bool> isAppInstalled(String packageName) async {
    if (!Platform.isAndroid) return false;

    try {
      final result = await _channel.invokeMethod('isAppInstalled', {
        'packageName': packageName,
      });
      return result as bool;
    } catch (e) {
      print('Error checking app installation: $e');
      return false;
    }
  }

  /// Get list of installed UPI apps
  static Future<List<String>> getInstalledApps(
    List<String> packageNames,
  ) async {
    if (!Platform.isAndroid) return [];

    try {
      final result = await _channel.invokeMethod('getInstalledApps', {
        'packageNames': packageNames,
      });
      return List<String>.from(result as List);
    } catch (e) {
      print('Error getting installed apps: $e');
      return [];
    }
  }

  /// Initiate UPI payment
  static Future<Map<String, dynamic>> initiatePayment({
    required String upiUrl,
    String? packageName,
  }) async {
    if (!Platform.isAndroid) {
      throw PlatformException(
        code: 'UNSUPPORTED_PLATFORM',
        message: 'UPI is only supported on Android',
      );
    }

    try {
      final result = await _channel.invokeMethod('initiatePayment', {
        'upiUrl': upiUrl,
        'packageName': packageName,
      });

      return Map<String, dynamic>.from(result as Map);
    } on PlatformException catch (e) {
      if (e.code == 'USER_CANCELED') {
        throw UpiUserCanceledException();
      }
      throw UpiPaymentFailedException(message: e.message ?? 'Unknown error');
    } catch (e) {
      throw UpiPaymentFailedException(message: e.toString());
    }
  }
}
```

### Step 2: Create Exception Classes

Create: `lib/features/upi_payment/exceptions/upi_exceptions.dart`

```dart
/// Base UPI exception
class UpiException implements Exception {
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const UpiException({
    required this.message,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'UpiException: $message';
}

/// UPI app not found exception
class UpiAppNotFoundException extends UpiException {
  UpiAppNotFoundException({
    String message = 'No UPI apps found on this device',
  }) : super(message: message);
}

/// User canceled payment exception
class UpiUserCanceledException extends UpiException {
  UpiUserCanceledException({
    String message = 'User canceled the payment',
  }) : super(message: message);
}

/// Payment failed exception
class UpiPaymentFailedException extends UpiException {
  UpiPaymentFailedException({
    required String message,
    dynamic originalError,
  }) : super(message: message, originalError: originalError);
}

/// Network exception
class UpiNetworkException extends UpiException {
  UpiNetworkException({
    String message = 'Network error occurred',
  }) : super(message: message);
}

/// Invalid VPA exception
class UpiInvalidVpaException extends UpiException {
  UpiInvalidVpaException({
    String message = 'Invalid UPI VPA',
  }) : super(message: message);
}

/// Timeout exception
class UpiTimeoutException extends UpiException {
  UpiTimeoutException({
    String message = 'Payment request timed out',
  }) : super(message: message);
}

/// Verification failed exception
class UpiVerificationException extends UpiException {
  UpiVerificationException({
    String message = 'Payment verification failed',
  }) : super(message: message);
}
```

### Step 3: Initialize in Your App

Edit your `main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:reuablewidgets/features/upi_payment/upi_payment.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize UPI payment module
  await initializeUpiPayment();

  runApp(MyApp());
}

Future<void> initializeUpiPayment() async {
  // Configure UPI payment module
  final config = UpiConfig(
    merchantVpa: 'yourmerchant@upi',  // Your UPI ID
    merchantName: 'Your Business Name',
    enabledApps: {
      'google_pay': true,
      'phonepe': true,
      'bhim': true,
      'paytm': false,
      'generic_upi': true,
    },
    enableServerVerification: true,
    verificationEndpoint: 'https://your-api.com/upi/verify',
    timeout: Duration(minutes: 5),
  );

  // Note: Actual initialization code to be implemented
  // based on the manager class
}
```

---

## Testing Setup

### Step 1: Install Test UPI Apps

On your test device/emulator, install:
- Google Pay (recommended for testing)
- PhonePe
- Any other UPI app

### Step 2: Test Payment Flow

Create a test screen:

```dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class TestPaymentScreen extends StatelessWidget {
  Future<void> _testPayment(BuildContext context) async {
    try {
      // Create test payment request
      final request = UpiPaymentRequest(
        payeeVpa: 'test@upi',  // Use test UPI ID
        payeeName: 'Test Merchant',
        transactionId: 'TEST_${Uuid().v4()}',
        transactionRef: 'REF_${DateTime.now().millisecondsSinceEpoch}',
        amount: 1.00,  // Use small amount for testing
        transactionNote: 'Test Payment',
        currency: 'INR',
      );

      // Note: Replace with actual implementation
      print('Testing payment: $request');

      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Test payment initiated')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test UPI Payment')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _testPayment(context),
          child: Text('Test Payment (₹1.00)'),
        ),
      ),
    );
  }
}
```

### Step 3: Test Scenarios

Test these scenarios:

1. **Successful Payment**
   - Enter valid UPI PIN
   - Verify success response
   - Check server verification

2. **User Cancellation**
   - Cancel payment in UPI app
   - Verify error handling

3. **Failed Payment**
   - Enter wrong UPI PIN
   - Verify failure response

4. **No Apps Installed**
   - Uninstall all UPI apps
   - Verify error message

5. **Network Error**
   - Turn off internet
   - Verify timeout handling

---

## Production Deployment

### Step 1: Server Setup

Implement server verification endpoint:

```
POST /api/v1/upi/verify
Content-Type: application/json
Authorization: Bearer <token>

Request Body:
{
  "transactionId": "TXN_xxx",
  "txnRef": "123456789",
  "approvalRef": "987654321",
  "amount": 299.00,
  "payeeVpa": "merchant@upi",
  "timestamp": "2025-11-14T10:30:00Z"
}

Response (Success):
{
  "verified": true,
  "transactionId": "TXN_xxx",
  "status": "SUCCESS"
}

Response (Failed):
{
  "verified": false,
  "reason": "Transaction not found"
}
```

### Step 2: Configure Production Settings

Update your production config:

```dart
final config = UpiConfig(
  merchantVpa: 'yourproduction@upi',
  merchantName: 'Your Company Name',
  enabledApps: {
    'google_pay': true,
    'phonepe': true,
    'bhim': true,
    'paytm': true,
    'generic_upi': true,
  },
  enableServerVerification: true,
  verificationEndpoint: 'https://api.yourapp.com/upi/verify',
  timeout: Duration(minutes: 5),
  enableLogging: false,  // Disable in production
);
```

### Step 3: Build Release APK

```bash
# Build release APK
flutter build apk --release

# Or build App Bundle for Play Store
flutter build appbundle --release
```

### Step 4: Test Production Build

1. Install release APK on test device
2. Make small real payments (₹1-₹10)
3. Verify all flows work
4. Check server logs
5. Verify database updates

### Step 5: Deploy to Play Store

1. Upload to Google Play Console
2. Complete store listing
3. Submit for review
4. Monitor crash reports
5. Monitor payment success rate

---

## Troubleshooting

### Issue: UPI App Not Detected

**Problem**: `isAppInstalled()` returns false even though app is installed

**Solutions**:
1. Check `AndroidManifest.xml` has correct `<queries>` section
2. Verify package names are correct
3. Test on Android 11+ device
4. Check logcat for errors:
```bash
adb logcat | grep -i upi
```

### Issue: Payment Intent Not Launching

**Problem**: UPI app doesn't open when payment is initiated

**Solutions**:
1. Verify UPI deep link format is correct
2. Check intent action and data in `UpiMethodChannel.kt`
3. Test with different UPI apps
4. Check for `ActivityNotFoundException` in logs

### Issue: Response Not Received

**Problem**: After completing payment in UPI app, no response received

**Solutions**:
1. Verify `onActivityResult` is implemented correctly
2. Check `REQUEST_CODE_UPI` matches in launch and result
3. Ensure activity is not being recreated
4. Add logs in `onActivityResult`:
```kotlin
override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    Log.d("UPI", "onActivityResult: requestCode=$requestCode, resultCode=$resultCode")
    // ... rest of code
}
```

### Issue: Server Verification Failing

**Problem**: Client receives success but server verification fails

**Solutions**:
1. Check server endpoint URL
2. Verify authentication token
3. Check transaction ID format
4. Review server logs
5. Ensure idempotency key handling

### Issue: ProGuard Issues in Release

**Problem**: App crashes in release build but works in debug

**Solutions**:
1. Check ProGuard rules in `proguard-rules.pro`
2. Add keep rules for method channel classes
3. Test release build before deployment
4. Use R8 full mode for better optimization

---

## Best Practices

### 1. Transaction Management
- Generate unique transaction IDs
- Store all transactions locally
- Implement server-side deduplication
- Log all payment attempts

### 2. Error Handling
- Handle all exception types
- Show user-friendly messages
- Provide retry options
- Log errors for monitoring

### 3. Security
- Validate amounts on server
- Check for duplicate transactions
- Implement rate limiting
- Use HTTPS for all API calls
- Store sensitive data securely

### 4. User Experience
- Show loading indicators
- Provide clear status updates
- Handle user cancellation gracefully
- Show transaction history
- Support multiple languages

### 5. Monitoring
- Track payment success rate
- Monitor server verification failures
- Log UPI app usage statistics
- Set up crash reporting
- Monitor API response times

---

## Support

### Documentation
- [README.md](README.md) - Usage guide
- [UPI_MODULE_SPECIFICATION.md](UPI_MODULE_SPECIFICATION.md) - Technical spec

### Debugging
```bash
# View Android logs
adb logcat | grep -i upi

# View Flutter logs
flutter logs

# Clear app data
adb shell pm clear com.yourcompany.yourapp
```

### Common Commands
```bash
# Check connected devices
adb devices

# Install APK
adb install app-release.apk

# Uninstall app
adb uninstall com.yourcompany.yourapp

# Check installed packages
adb shell pm list packages | grep upi
```

---

## Checklist

### Development
- [ ] Module copied to project
- [ ] Dependencies added to pubspec.yaml
- [ ] Android method channel created
- [ ] MainActivity updated
- [ ] AndroidManifest.xml configured
- [ ] ProGuard rules added
- [ ] Platform channel interface created
- [ ] Exception classes added
- [ ] Configuration completed

### Testing
- [ ] Test UPI apps installed
- [ ] Successful payment tested
- [ ] User cancellation tested
- [ ] Failed payment tested
- [ ] Network error tested
- [ ] Server verification tested
- [ ] Release build tested

### Production
- [ ] Server verification endpoint implemented
- [ ] Production config updated
- [ ] Release APK built and tested
- [ ] Small real payments tested
- [ ] Monitoring set up
- [ ] Error logging configured
- [ ] Play Store listing ready
- [ ] Submitted for review

---

**Document Status**: Complete Setup Guide
**Last Updated**: 2025-11-14
**Version**: 1.0.0
