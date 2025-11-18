import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

/// Email provider types
enum EmailProviderType {
  gmail,
  outlook,
  yahoo,
  custom,
}

/// Email configuration state
class EmailConfig {
  final String? email;
  final String? displayName;
  final EmailProviderType? provider;
  final bool isConfigured;
  final String? errorMessage;
  final bool isLoading;

  const EmailConfig({
    this.email,
    this.displayName,
    this.provider,
    this.isConfigured = false,
    this.errorMessage,
    this.isLoading = false,
  });

  EmailConfig copyWith({
    String? email,
    String? displayName,
    EmailProviderType? provider,
    bool? isConfigured,
    String? errorMessage,
    bool? isLoading,
  }) {
    return EmailConfig(
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      provider: provider ?? this.provider,
      isConfigured: isConfigured ?? this.isConfigured,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Email provider state notifier
class EmailProviderNotifier extends StateNotifier<EmailConfig> {
  EmailProviderNotifier() : super(const EmailConfig());

  /// Configure email provider
  Future<bool> configure({
    required String email,
    required String password,
    required String displayName,
    required EmailProviderType provider,
    String? customSmtpHost,
    int? customSmtpPort,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Validate configuration by attempting to create SMTP connection
      final smtpServer = _getSmtpServer(
        provider: provider,
        email: email,
        password: password,
        customHost: customSmtpHost,
        customPort: customSmtpPort,
      );

      // Test connection (optional - can be commented out for faster config)
      // final connection = PersistentConnection(smtpServer);
      // await connection.send(Message()..subject = 'Test');
      // await connection.close();

      state = state.copyWith(
        email: email,
        displayName: displayName,
        provider: provider,
        isConfigured: true,
        isLoading: false,
        errorMessage: null,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to configure email: $e',
        isConfigured: false,
      );
      return false;
    }
  }

  /// Send email using configured provider
  Future<bool> sendEmail({
    required String to,
    required String subject,
    required String body,
    String? password,
    bool isHtml = false,
  }) async {
    if (!state.isConfigured || state.email == null || password == null) {
      state = state.copyWith(
        errorMessage: 'Email not configured. Please configure first.',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final smtpServer = _getSmtpServer(
        provider: state.provider!,
        email: state.email!,
        password: password,
      );

      final message = Message()
        ..from = Address(state.email!, state.displayName ?? '')
        ..recipients.add(to)
        ..subject = subject;

      if (isHtml) {
        message.html = body;
      } else {
        message.text = body;
      }

      final sendReport = await send(message, smtpServer);

      state = state.copyWith(
        isLoading: false,
        errorMessage: null,
      );

      // Log success - in production this should use proper logging
      print('Email sent successfully to $to: $sendReport');

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to send email: $e',
      );
      return false;
    }
  }

  /// Get SMTP server configuration based on provider
  SmtpServer _getSmtpServer({
    required EmailProviderType provider,
    required String email,
    required String password,
    String? customHost,
    int? customPort,
  }) {
    switch (provider) {
      case EmailProviderType.gmail:
        return gmail(email, password);

      case EmailProviderType.outlook:
        return hotmail(email, password);

      case EmailProviderType.yahoo:
        return yahoo(email, password);

      case EmailProviderType.custom:
        if (customHost == null || customPort == null) {
          throw ArgumentError('Custom SMTP requires host and port');
        }
        return SmtpServer(
          customHost,
          port: customPort,
          username: email,
          password: password,
          ssl: true,
        );
    }
  }

  /// Clear configuration
  void clearConfig() {
    state = const EmailConfig();
  }

  /// Get provider display name
  String getProviderName() {
    switch (state.provider) {
      case EmailProviderType.gmail:
        return 'Gmail';
      case EmailProviderType.outlook:
        return 'Outlook';
      case EmailProviderType.yahoo:
        return 'Yahoo';
      case EmailProviderType.custom:
        return 'Custom SMTP';
      case null:
        return 'Not configured';
    }
  }
}

/// Email provider instance
final emailProvider = StateNotifierProvider<EmailProviderNotifier, EmailConfig>(
  (ref) => EmailProviderNotifier(),
);
