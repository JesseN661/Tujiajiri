import 'package:flutter/material.dart';

/// Outlined form field; password fields get a show/hide toggle.
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.helperText,
    this.isPassword = false,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final String? helperText;
  final bool isPassword;
  final VoidCallback? onSubmitted;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  // A notifier keeps the toggle local without calling setState.
  final ValueNotifier<bool> _obscured = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _obscured.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _obscured,
      builder: (context, obscured, _) {
        return TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          obscureText: widget.isPassword && obscured,
          onFieldSubmitted: widget.onSubmitted == null
              ? null
              : (_) => widget.onSubmitted!(),
          decoration: InputDecoration(
            labelText: widget.label,
            helperText: widget.helperText,
            helperMaxLines: 2,
            prefixIcon: Icon(widget.icon),
            border: const OutlineInputBorder(),
            suffixIcon: widget.isPassword
                ? IconButton(
                    tooltip: obscured ? 'Show password' : 'Hide password',
                    icon: Icon(
                      obscured ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => _obscured.value = !obscured,
                  )
                : null,
          ),
        );
      },
    );
  }
}
