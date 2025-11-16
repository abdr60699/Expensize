import 'package:flutter/material.dart';
import '../models/app_lock_config.dart';
import '../models/pin_verify_result.dart';
import '../app_lock_manager.dart';
import 'pin_pad.dart';
import 'lock_indicator.dart';
import '../utils/time_utils.dart';

/// Mode for the lock screen
enum AppLockMode {
  /// Initial PIN setup (enter + confirm)
  setup,

  /// PIN verification for unlocking
  verify,

  /// Change PIN (old + new + confirm)
  change,
}

/// Main app lock screen widget
///
/// Provides UI for:
/// - Setting up a new PIN
/// - Verifying PIN to unlock
/// - Changing existing PIN
/// - Biometric authentication
///
/// Handles different modes and provides callbacks for completion.
class AppLockScreen extends StatefulWidget {
  /// App lock manager instance
  final AppLockManager manager;

  /// Lock screen mode
  final AppLockMode mode;

  /// Callback when verification succeeds
  final VoidCallback? onVerified;

  /// Callback when setup completes
  final VoidCallback? onSetupComplete;

  /// Callback when change PIN completes
  final VoidCallback? onChangeComplete;

  /// Callback when cancelled
  final VoidCallback? onCancelled;

  /// Custom title (overrides default)
  final String? title;

  /// Custom subtitle (overrides default)
  final String? subtitle;

  /// Whether to show biometric button
  final bool showBiometric;

  /// Whether to show cancel button
  final bool showCancel;

  /// Background color
  final Color? backgroundColor;

  /// Primary color for UI elements
  final Color? primaryColor;

  /// Text color
  final Color? textColor;

  const AppLockScreen({
    super.key,
    required this.manager,
    this.mode = AppLockMode.verify,
    this.onVerified,
    this.onSetupComplete,
    this.onChangeComplete,
    this.onCancelled,
    this.title,
    this.subtitle,
    this.showBiometric = true,
    this.showCancel = false,
    this.backgroundColor,
    this.primaryColor,
    this.textColor,
  });

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  String _pin = '';
  String _confirmPin = '';
  String _oldPin = '';
  String _message = '';
  bool _isError = false;
  bool _isSuccess = false;
  bool _isProcessing = false;
  PinVerifyResult? _lastResult;

  // Setup flow step
  int _setupStep = 0; // 0 = enter, 1 = confirm

  // Change flow step
  int _changeStep = 0; // 0 = old, 1 = new, 2 = confirm

  @override
  void initState() {
    super.initState();
    _initializeScreen();
    _tryBiometricOnStart();
  }

  void _initializeScreen() {
    switch (widget.mode) {
      case AppLockMode.setup:
        _message = 'Enter a PIN';
        break;
      case AppLockMode.verify:
        _message = 'Enter your PIN to unlock';
        break;
      case AppLockMode.change:
        _message = 'Enter your current PIN';
        break;
    }
  }

  Future<void> _tryBiometricOnStart() async {
    if (!widget.showBiometric) return;
    if (widget.mode != AppLockMode.verify) return;

    // Small delay to let UI settle
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    final success = await widget.manager.authenticateBiometric();
    if (success && mounted) {
      await widget.manager.unlock();
      widget.onVerified?.call();
    }
  }

  void _onDigitPressed(String digit) {
    if (_isProcessing) return;

    setState(() {
      _isError = false;
      _isSuccess = false;

      switch (widget.mode) {
        case AppLockMode.setup:
          if (_setupStep == 0) {
            if (_pin.length < 10) {
              _pin += digit;
              if (_pin.length >= widget.manager.config.pinMinLength) {
                // Can proceed to confirm
              }
            }
          } else {
            if (_confirmPin.length < 10) {
              _confirmPin += digit;
            }
          }
          break;

        case AppLockMode.verify:
          if (_pin.length < 10) {
            _pin += digit;
          }
          break;

        case AppLockMode.change:
          if (_changeStep == 0) {
            if (_oldPin.length < 10) {
              _oldPin += digit;
            }
          } else if (_changeStep == 1) {
            if (_pin.length < 10) {
              _pin += digit;
            }
          } else {
            if (_confirmPin.length < 10) {
              _confirmPin += digit;
            }
          }
          break;
      }

      _updateMessage();
    });
  }

  void _onBackspace() {
    if (_isProcessing) return;

    setState(() {
      _isError = false;
      _isSuccess = false;

      switch (widget.mode) {
        case AppLockMode.setup:
          if (_setupStep == 0 && _pin.isNotEmpty) {
            _pin = _pin.substring(0, _pin.length - 1);
          } else if (_setupStep == 1 && _confirmPin.isNotEmpty) {
            _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
          }
          break;

        case AppLockMode.verify:
          if (_pin.isNotEmpty) {
            _pin = _pin.substring(0, _pin.length - 1);
          }
          break;

        case AppLockMode.change:
          if (_changeStep == 0 && _oldPin.isNotEmpty) {
            _oldPin = _oldPin.substring(0, _oldPin.length - 1);
          } else if (_changeStep == 1 && _pin.isNotEmpty) {
            _pin = _pin.substring(0, _pin.length - 1);
          } else if (_changeStep == 2 && _confirmPin.isNotEmpty) {
            _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
          }
          break;
      }

      _updateMessage();
    });
  }

  void _updateMessage() {
    switch (widget.mode) {
      case AppLockMode.setup:
        if (_setupStep == 0) {
          _message = _pin.isEmpty
              ? 'Enter a PIN'
              : _pin.length < widget.manager.config.pinMinLength
                  ? 'PIN must be at least ${widget.manager.config.pinMinLength} digits'
                  : 'Press Done to continue';
        } else {
          _message = _confirmPin.isEmpty
              ? 'Confirm your PIN'
              : 'Press Done to set PIN';
        }
        break;

      case AppLockMode.verify:
        if (_isError) {
          // Message already set by error
        } else {
          _message = _pin.isEmpty
              ? 'Enter your PIN to unlock'
              : '';
        }
        break;

      case AppLockMode.change:
        if (_changeStep == 0) {
          _message = _oldPin.isEmpty
              ? 'Enter your current PIN'
              : 'Press Done to continue';
        } else if (_changeStep == 1) {
          _message = _pin.isEmpty
              ? 'Enter new PIN'
              : _pin.length < widget.manager.config.pinMinLength
                  ? 'PIN must be at least ${widget.manager.config.pinMinLength} digits'
                  : 'Press Done to continue';
        } else {
          _message = _confirmPin.isEmpty
              ? 'Confirm new PIN'
              : 'Press Done to change PIN';
        }
        break;
    }
  }

  Future<void> _onDone() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    switch (widget.mode) {
      case AppLockMode.setup:
        await _handleSetup();
        break;

      case AppLockMode.verify:
        await _handleVerify();
        break;

      case AppLockMode.change:
        await _handleChange();
        break;
    }

    if (mounted) {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleSetup() async {
    if (_setupStep == 0) {
      if (_pin.length < widget.manager.config.pinMinLength) {
        _showError('PIN must be at least ${widget.manager.config.pinMinLength} digits');
        return;
      }

      setState(() {
        _setupStep = 1;
        _confirmPin = '';
        _updateMessage();
      });
    } else {
      if (_pin != _confirmPin) {
        _showError('PINs do not match');
        setState(() {
          _setupStep = 0;
          _pin = '';
          _confirmPin = '';
          _updateMessage();
        });
        return;
      }

      final success = await widget.manager.setPin(_pin);
      if (success && mounted) {
        _showSuccess('PIN set successfully');
        await Future.delayed(const Duration(milliseconds: 500));
        widget.onSetupComplete?.call();
      } else {
        _showError('Failed to set PIN');
      }
    }
  }

  Future<void> _handleVerify() async {
    if (_pin.isEmpty) return;

    final result = await widget.manager.verifyPin(_pin);
    _lastResult = result;

    if (result.success && mounted) {
      _showSuccess('Unlocked');
      await widget.manager.unlock();
      await Future.delayed(const Duration(milliseconds: 300));
      widget.onVerified?.call();
    } else if (result.lockedOut && mounted) {
      _showError(result.message ?? 'Locked out');
    } else if (mounted) {
      _showError(result.message ?? 'Incorrect PIN');
      setState(() {
        _pin = '';
      });
    }
  }

  Future<void> _handleChange() async {
    if (_changeStep == 0) {
      final result = await widget.manager.verifyPin(_oldPin);
      if (result.success && mounted) {
        setState(() {
          _changeStep = 1;
          _pin = '';
          _updateMessage();
        });
      } else if (mounted) {
        _showError(result.message ?? 'Incorrect PIN');
        setState(() {
          _oldPin = '';
        });
      }
    } else if (_changeStep == 1) {
      if (_pin.length < widget.manager.config.pinMinLength) {
        _showError('PIN must be at least ${widget.manager.config.pinMinLength} digits');
        return;
      }

      setState(() {
        _changeStep = 2;
        _confirmPin = '';
        _updateMessage();
      });
    } else {
      if (_pin != _confirmPin) {
        _showError('PINs do not match');
        setState(() {
          _changeStep = 1;
          _pin = '';
          _confirmPin = '';
          _updateMessage();
        });
        return;
      }

      final success = await widget.manager.changePin(
        oldPin: _oldPin,
        newPin: _pin,
      );

      if (success && mounted) {
        _showSuccess('PIN changed successfully');
        await Future.delayed(const Duration(milliseconds: 500));
        widget.onChangeComplete?.call();
      } else {
        _showError('Failed to change PIN');
      }
    }
  }

  void _showError(String message) {
    setState(() {
      _message = message;
      _isError = true;
      _isSuccess = false;
    });
  }

  void _showSuccess(String message) {
    setState(() {
      _message = message;
      _isSuccess = true;
      _isError = false;
    });
  }

  String _getCurrentPin() {
    switch (widget.mode) {
      case AppLockMode.setup:
        return _setupStep == 0 ? _pin : _confirmPin;
      case AppLockMode.verify:
        return _pin;
      case AppLockMode.change:
        if (_changeStep == 0) return _oldPin;
        if (_changeStep == 1) return _pin;
        return _confirmPin;
    }
  }

  bool _canShowDone() {
    switch (widget.mode) {
      case AppLockMode.setup:
        if (_setupStep == 0) {
          return _pin.length >= widget.manager.config.pinMinLength;
        } else {
          return _confirmPin.isNotEmpty;
        }

      case AppLockMode.verify:
        return _pin.isNotEmpty;

      case AppLockMode.change:
        if (_changeStep == 0) return _oldPin.isNotEmpty;
        if (_changeStep == 1) {
          return _pin.length >= widget.manager.config.pinMinLength;
        }
        return _confirmPin.isNotEmpty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = widget.backgroundColor ?? theme.scaffoldBackgroundColor;
    final primaryCol = widget.primaryColor ?? theme.colorScheme.primary;
    final textCol = widget.textColor ?? theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: widget.showCancel
          ? AppBar(
              backgroundColor: bgColor,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onCancelled,
              ),
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header
              Column(
                children: [
                  const SizedBox(height: 40),
                  Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: primaryCol,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.title ?? _getDefaultTitle(),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: textCol,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.subtitle ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: textCol.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              // PIN Indicator and Message
              Column(
                children: [
                  LockIndicator(
                    currentLength: _getCurrentPin().length,
                    targetLength: widget.manager.config.pinMinLength,
                    filledColor: _isSuccess
                        ? Colors.green
                        : _isError
                            ? Colors.red
                            : primaryCol,
                    showError: _isError,
                    showSuccess: _isSuccess,
                  ),
                  const SizedBox(height: 24),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 60,
                    child: Center(
                      child: Text(
                        _message,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: _isError
                              ? Colors.red
                              : _isSuccess
                                  ? Colors.green
                                  : textCol,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  if (_lastResult != null && _lastResult!.lockedOut)
                    Text(
                      _lastResult!.lockoutDuration != null
                          ? 'Try again in ${TimeUtils.formatRemainingTime(_lastResult!.lockoutDuration!)}'
                          : '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.red,
                      ),
                    ),
                ],
              ),

              // PIN Pad and Actions
              Column(
                children: [
                  PinPad(
                    onDigitPressed: _onDigitPressed,
                    onBackspace: _onBackspace,
                    buttonColor: primaryCol.withOpacity(0.1),
                    textColor: textCol,
                    enabled: !_isProcessing &&
                        (!(_lastResult?.lockedOut ?? false)),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Biometric button
                      if (widget.showBiometric && widget.mode == AppLockMode.verify)
                        IconButton(
                          onPressed: _isProcessing ? null : () async {
                            final success =
                                await widget.manager.authenticateBiometric();
                            if (success && mounted) {
                              await widget.manager.unlock();
                              widget.onVerified?.call();
                            }
                          },
                          icon: const Icon(Icons.fingerprint),
                          iconSize: 40,
                          color: primaryCol,
                        )
                      else
                        const SizedBox(width: 40),

                      // Done button
                      if (_canShowDone())
                        ElevatedButton(
                          onPressed: _isProcessing ? null : _onDone,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryCol,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                          ),
                          child: _isProcessing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text('Done'),
                        )
                      else
                        const SizedBox(width: 40),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDefaultTitle() {
    switch (widget.mode) {
      case AppLockMode.setup:
        return 'Set Up PIN';
      case AppLockMode.verify:
        return 'Unlock';
      case AppLockMode.change:
        return 'Change PIN';
    }
  }
}
