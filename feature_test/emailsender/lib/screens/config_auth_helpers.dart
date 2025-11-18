import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../main.dart';

/// Extension methods for ConfigScreen authentication helpers
extension ConfigAuthHelpers on _ConfigScreenState {
  /// Loads saved password for the current email
  Future<void> loadSavedPassword() async {
    if (_hasSavedPassword && _emailController.text.isNotEmpty) {
      final savedPassword = await _secureStorage.read(
        key: 'password_${_emailController.text}',
      );
      if (mounted && savedPassword != null) {
        _hasSavedPassword = true;
      } else {
        _hasSavedPassword = false;
      }
      setState(() {
        _savePassword = _hasSavedPassword;
        _isAuthenticatedThisSession = false;
      });
    } else {
      setState(() {
        _hasSavedPassword = false;
        _isAuthenticatedThisSession = false;
      });
    }
  }

  /// Checks if biometric authentication is available
  Future<bool> checkBiometricAvailability() async {
    try {
      final canCheckBiometrics = await _biometricAuth.canCheckBiometrics;
      if (canCheckBiometrics) {
        _biometricType = 'fingerprint'; // Simplified
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Handles biometric authentication
  Future<void> handleBiometricAuth() async {
    if (_authInProgress) return;

    setState(() {
      _authInProgress = true;
    });

    try {
      final authenticated = await _biometricAuth.authenticate(
        localizedReason: 'Authenticate to access saved credentials',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      if (!mounted) return;

      if (authenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication successful'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _authInProgress = false;
          _isAuthenticatedThisSession = true;
        });
        await _loadCredentials();
      } else {
        setState(() {
          _authInProgress = false;
        });
      }
    } catch (e) {
      setState(() {
        _authInProgress = false;
        _isAuthenticatedThisSession = false;
      });
    }
  }

  /// Loads saved credentials after successful authentication
  Future<void> _loadCredentials() async {
    if (_hasSavedPassword && _emailController.text.isNotEmpty) {
      final savedPassword = await _secureStorage.read(
        key: 'password_${_emailController.text}',
      );
      final savedName = await _secureStorage.read(
        key: 'name_${_emailController.text}',
      );

      if (mounted) {
        _passwordController.text = savedPassword ?? '';
        _obscurePassword = false;

        if (savedName != null) _nameController.text = savedName;
      }
    }
  }

  /// Handles manual password authentication
  Future<void> handlePasswordAuth() async {
    if (_hasSavedPassword && _emailController.text.isNotEmpty) {
      setState(() {
        _authInProgress = true;
      });

      setState(() {
        _authInProgress = false;
        _isAuthenticatedThisSession = true;
      });

      // Show dialog for password entry
      final authenticated = await _showPasswordDialog();

      if (authenticated) {
        await _loadCredentials();
      }
    }
  }

  /// Shows password entry dialog
  Future<bool> _showPasswordDialog() async {
    if (_hasSavedPassword && _emailController.text.isNotEmpty) {
      setState(() {
        _authInProgress = true;
      });

      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          final passwordController = TextEditingController();
          return AlertDialog(
            title: const Text('Enter Password'),
            content: TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final savedPassword = await _secureStorage.read(
                    key: 'password_${_emailController.text}',
                  );
                  if (passwordController.text == savedPassword) {
                    if (context.mounted) {
                      Navigator.pop(context, true);
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Incorrect password'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Authenticate'),
              ),
            ],
          );
        },
      );

      setState(() {
        _authInProgress = false;
        _isAuthenticatedThisSession = result ?? false;
      });

      return result ?? false;
    }
    return false;
  }

  /// Handles clearing saved credentials
  Future<void> handleClearCredentials() async {
    if (_hasSavedPassword && _emailController.text.isNotEmpty) {
      setState(() {
        _authInProgress = true;
      });

      try {
        await _secureStorage.delete(key: 'email_${_emailController.text}');
        await _secureStorage.delete(key: 'password_${_emailController.text}');
        await _secureStorage.delete(key: 'name_${_emailController.text}');

        await Clipboard.setData(const ClipboardData(text: ''));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Credentials cleared'),
              backgroundColor: Colors.green,
            ),
          );
        }

        setState(() {
          _authInProgress = false;
          _hasSavedPassword = false;
          _isAuthenticatedThisSession = false;
        });
      } catch (e) {
        setState(() {
          _authInProgress = false;
        });
      }
    }
  }
}
