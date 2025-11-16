// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart';
import '../../utils/validators.dart';
import '../widgets/auth_text_field.dart';
import 'dart:async';

/// Example Phone Sign-In Screen
///
/// Demonstrates:
/// - Phone number verification flow
/// - OTP code entry
/// - Resend functionality with cooldown
/// - Auto-retrieval on Android
class PhoneSignInScreen extends ConsumerStatefulWidget {
  const PhoneSignInScreen({super.key});

  @override
  ConsumerState<PhoneSignInScreen> createState() => _PhoneSignInScreenState();
}

class _PhoneSignInScreenState extends ConsumerState<PhoneSignInScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _codeSent = false;
  Timer? _resendTimer;
  int _resendCountdown = 0;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final phone = _phoneController.text.trim();
    if (AuthValidators.validatePhoneNumber(phone) != null) {
      _showError('Please enter a valid phone number');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      final credential = await authService.signInWithPhone(phone);

      if (credential != null) {
        // Auto-retrieved on Android
        await _signInWithCredential(credential);
      } else {
        // Show OTP input for manual entry
        setState(() {
          _codeSent = true;
          _isLoading = false;
        });
        _startResendTimer();
        _showMessage('Verification code sent to $phone');
      }
    } catch (e) {
      _showError('Failed to send code. Please try again.');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyCode() async {
    final code = _otpController.text.trim();
    if (AuthValidators.validateOtpCode(code) != null) {
      _showError('Please enter a valid 6-digit code');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      final credential = authService.verifyPhoneOtp(code);
      await _signInWithCredential(credential);
    } catch (e) {
      _showError('Invalid code. Please try again.');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithCredential(credential) async {
    try {
      final authRepository = ref.read(authRepositoryProvider);
      final result = await authRepository.signInWithCredential(credential);

      if (result.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sign in successful!')),
          );
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        _showError(result.error!.friendlyMessage);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendCode() async {
    await _sendCode();
  }

  void _startResendTimer() {
    _resendCountdown = 30; // 30 seconds cooldown
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _resendCountdown--;
      });
      if (_resendCountdown == 0) {
        timer.cancel();
      }
    });
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Sign In'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon
              const Icon(Icons.phone_android, size: 80),
              const SizedBox(height: 24),

              // Title
              Text(
                _codeSent ? 'Verify Code' : 'Enter Phone Number',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                _codeSent
                    ? 'Enter the 6-digit code sent to ${_phoneController.text}'
                    : 'We will send you a verification code',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Phone input
              if (!_codeSent) ...[
                PhoneTextField(
                  controller: _phoneController,
                  validator: AuthValidators.validatePhoneNumber,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _sendCode(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendCode,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Send Code'),
                  ),
                ),
              ]

              // OTP input
              else ...[
                OtpTextField(
                  controller: _otpController,
                  validator: AuthValidators.validateOtpCode,
                  onSubmitted: (_) => _verifyCode(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyCode,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Verify'),
                  ),
                ),
                const SizedBox(height: 16),

                // Resend code
                Center(
                  child: _resendCountdown > 0
                      ? Text(
                          'Resend code in $_resendCountdown seconds',
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      : TextButton(
                          onPressed: _isLoading ? null : _resendCode,
                          child: const Text('Resend Code'),
                        ),
                ),

                // Change number
                Center(
                  child: TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            setState(() {
                              _codeSent = false;
                              _otpController.clear();
                              _resendTimer?.cancel();
                            });
                          },
                    child: const Text('Change Number'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
