import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Outlined text field used by every onboarding form.
class ProfileTextField extends StatelessWidget {
  const ProfileTextField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.icon,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.helperText,
    this.maxLength,
    this.maxLines = 1,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final IconData? icon;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final String? helperText;
  final int? maxLength;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLength: maxLength,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        helperMaxLines: 2,
        alignLabelWithHint: maxLines > 1,
        prefixIcon: icon == null ? null : Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
