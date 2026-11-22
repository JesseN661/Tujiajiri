import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';

/// Full-width button that shows a spinner and disables itself while busy.
class AuthSubmitButton extends StatelessWidget {
  const AuthSubmitButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AuthCubit, AuthState, bool>(
      selector: (state) => state.isBusy,
      builder: (context, isBusy) {
        return FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          onPressed: isBusy ? null : onPressed,
          child: isBusy
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : Text(label),
        );
      },
    );
  }
}
