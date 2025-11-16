import 'package:flutter/material.dart';

/// Reusable text field for authentication forms
///
/// Includes validation, password visibility toggle, and consistent styling.
class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final bool enabled;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final Function(String)? onSubmitted;
  final bool autocorrect;
  final bool enableSuggestions;
  final AutovalidateMode? autovalidateMode;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.prefixIcon,
    this.enabled = true,
    this.maxLines = 1,
    this.textInputAction,
    this.onSubmitted,
    this.autocorrect = false,
    this.enableSuggestions = false,
    this.autovalidateMode,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText && !_isPasswordVisible,
      validator: widget.validator,
      enabled: widget.enabled,
      maxLines: widget.maxLines,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onSubmitted,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.enableSuggestions,
      autovalidateMode: widget.autovalidateMode,
    );
  }
}

/// Password text field with show/hide toggle
class PasswordTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final Function(String)? onSubmitted;
  final AutovalidateMode? autovalidateMode;

  const PasswordTextField({
    super.key,
    required this.controller,
    this.label = 'Password',
    this.hint,
    this.validator,
    this.textInputAction,
    this.onSubmitted,
    this.autovalidateMode,
  });

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      controller: controller,
      label: label,
      hint: hint,
      keyboardType: TextInputType.visiblePassword,
      obscureText: true,
      validator: validator,
      prefixIcon: const Icon(Icons.lock_outline),
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      autocorrect: false,
      enableSuggestions: false,
      autovalidateMode: autovalidateMode,
    );
  }
}

/// Email text field
class EmailTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final Function(String)? onSubmitted;
  final AutovalidateMode? autovalidateMode;

  const EmailTextField({
    super.key,
    required this.controller,
    this.label = 'Email',
    this.hint,
    this.validator,
    this.textInputAction,
    this.onSubmitted,
    this.autovalidateMode,
  });

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      controller: controller,
      label: label,
      hint: hint,
      keyboardType: TextInputType.emailAddress,
      validator: validator,
      prefixIcon: const Icon(Icons.email_outlined),
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      autocorrect: false,
      enableSuggestions: false,
      autovalidateMode: autovalidateMode,
    );
  }
}

/// Phone number text field
class PhoneTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final Function(String)? onSubmitted;
  final AutovalidateMode? autovalidateMode;

  const PhoneTextField({
    super.key,
    required this.controller,
    this.label = 'Phone Number',
    this.hint = '+1234567890',
    this.validator,
    this.textInputAction,
    this.onSubmitted,
    this.autovalidateMode,
  });

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      controller: controller,
      label: label,
      hint: hint,
      keyboardType: TextInputType.phone,
      validator: validator,
      prefixIcon: const Icon(Icons.phone_outlined),
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      autocorrect: false,
      enableSuggestions: false,
      autovalidateMode: autovalidateMode,
    );
  }
}

/// OTP code text field
class OtpTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final Function(String)? onSubmitted;
  final AutovalidateMode? autovalidateMode;
  final int length;

  const OtpTextField({
    super.key,
    required this.controller,
    this.label = 'Verification Code',
    this.hint = '123456',
    this.validator,
    this.onSubmitted,
    this.autovalidateMode,
    this.length = 6,
  });

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      controller: controller,
      label: label,
      hint: hint,
      keyboardType: TextInputType.number,
      validator: validator,
      prefixIcon: const Icon(Icons.sms_outlined),
      onSubmitted: onSubmitted,
      autocorrect: false,
      enableSuggestions: false,
      autovalidateMode: autovalidateMode,
      textInputAction: TextInputAction.done,
    );
  }
}
