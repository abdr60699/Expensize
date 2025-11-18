import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'screens/config_auth_helpers.dart';
import 'providers/email_provider_actions.dart';

/// Main app entry point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: EmailSenderApp(),
    ),
  );
}

class EmailSenderApp extends StatelessWidget {
  const EmailSenderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Email Sender Configuration',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ConfigScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Email provider configuration screen
class ConfigScreen extends ConsumerStatefulWidget {
  const ConfigScreen({super.key});

  @override
  ConsumerState<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends ConsumerState<ConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _secureStorage = const FlutterSecureStorage();
  final _biometricAuth = LocalAuthentication();

  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _nameController;

  EmailProviderType _selectedProvider = EmailProviderType.gmail;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _savePassword = false;
  bool _hasSavedPassword = false;
  bool _isAuthenticatedThisSession = false;
  bool _authInProgress = false;
  String? _biometricType;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _nameController = TextEditingController();
    _loadSavedEmail();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedEmail() async {
    final savedEmail = await _secureStorage.read(key: 'email_${_emailController.text}');
    final savedPassword = await _secureStorage.read(key: 'password_${_emailController.text}');
    final savedName = await _secureStorage.read(key: 'name_${_emailController.text}');

    if (mounted) {
      setState(() {
        if (savedEmail != null) _emailController.text = savedEmail;
        if (savedPassword != null) _hasSavedPassword = true;
        if (savedName != null) _nameController.text = savedName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Configuration'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelp(context),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Provider selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Email Provider',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<EmailProviderType>(
                      value: _selectedProvider,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: EmailProviderType.values.map((provider) {
                        return DropdownMenuItem(
                          value: provider,
                          child: Text(_getProviderName(provider)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedProvider = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Email configuration
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Account Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Display Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password / App Password',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscurePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text('Save password securely'),
                      subtitle: const Text('Store password for future use'),
                      value: _savePassword,
                      onChanged: (value) {
                        setState(() {
                          _savePassword = value ?? false;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Actions
            if (_hasSavedPassword) ...[
              ElevatedButton.icon(
                onPressed: _authInProgress ? null : _handleBiometricAuth,
                icon: const Icon(Icons.fingerprint),
                label: const Text('Authenticate with Biometrics'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _authInProgress ? null : _handlePasswordAuth,
                icon: const Icon(Icons.password),
                label: const Text('Enter Password Manually'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _authInProgress ? null : _handleClearCredentials,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Clear Saved Credentials'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Configuration'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getProviderName(EmailProviderType provider) {
    switch (provider) {
      case EmailProviderType.gmail:
        return 'Gmail';
      case EmailProviderType.outlook:
        return 'Outlook';
      case EmailProviderType.yahoo:
        return 'Yahoo';
      case EmailProviderType.custom:
        return 'Custom SMTP';
    }
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Help'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Email Configuration Help',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '1. Select your email provider\n'
                '2. Enter your display name\n'
                '3. Enter your email address\n'
                '4. For Gmail/Outlook, use an App Password\n'
                '5. Optionally save password for future use\n\n'
                'App passwords provide better security than your regular password.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Handle biometric authentication
  Future<void> _handleBiometricAuth() async {
    await handleBiometricAuth();
  }

  /// Handle password authentication
  Future<void> _handlePasswordAuth() async {
    await handlePasswordAuth();
  }

  /// Handle clearing credentials
  Future<void> _handleClearCredentials() async {
    await handleClearCredentials();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Save credentials if requested
      if (_savePassword) {
        await _secureStorage.write(
          key: 'email_${_emailController.text}',
          value: _emailController.text,
        );
        await _secureStorage.write(
          key: 'password_${_emailController.text}',
          value: _passwordController.text,
        );
        await _secureStorage.write(
          key: 'name_${_emailController.text}',
          value: _nameController.text,
        );
      } else {
        await _secureStorage.delete(key: 'email_${_emailController.text}');
        await _secureStorage.delete(key: 'password_${_emailController.text}');
        await _secureStorage.delete(key: 'name_${_emailController.text}');
      }

      if (!mounted) return;

      // Save to provider
      final result = await ref.read(emailProvider.notifier).configure(
            email: _emailController.text,
            password: _passwordController.text,
            displayName: _nameController.text,
            provider: _selectedProvider,
          );

      setState(() => _isLoading = false);

      if (!mounted) return;

      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Configuration saved for $_selectedProvider'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        final errorMessage = ref.read(emailProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage ?? 'Failed to save configuration'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
