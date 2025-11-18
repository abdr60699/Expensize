# Email Sender Module

A Flutter module for configuring and sending emails through various email providers with secure authentication.

## Features

- **Multiple Email Providers**: Support for Gmail, Outlook, Yahoo, and custom SMTP servers
- **Secure Storage**: Passwords are stored securely using flutter_secure_storage
- **Biometric Authentication**: Optional biometric authentication for accessing saved credentials
- **Configuration Screen**: User-friendly interface for email setup
- **State Management**: Uses Riverpod for clean state management

## Components

### Main Screen
- `ConfigScreen`: The main configuration screen for setting up email providers
- Supports saving credentials securely
- Biometric authentication for enhanced security

### Providers
- `EmailProviderNotifier`: Manages email configuration state
- `emailProvider`: Riverpod provider for accessing email functionality

### Helper Files
- `config_auth_helpers.dart`: Extension methods for authentication helpers

## Usage

```dart
import 'package:emailsender/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Wrap your app with ProviderScope
runApp(
  const ProviderScope(
    child: EmailSenderApp(),
  ),
);
```

## Configuration

1. Select your email provider (Gmail, Outlook, Yahoo, or Custom)
2. Enter your display name
3. Enter your email address
4. Enter your password or app-specific password
5. Optionally save credentials for future use

## Security Notes

- For Gmail and Outlook, use app-specific passwords instead of your main password
- All credentials are stored using Flutter's secure storage
- Biometric authentication provides an additional layer of security

## Dependencies

- `flutter_riverpod`: State management
- `flutter_secure_storage`: Secure credential storage
- `local_auth`: Biometric authentication
- `mailer`: Email sending functionality
