import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';

/// "Continue with Google" button, with an "or" divider above it.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('or'),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 16),
        BlocSelector<AuthCubit, AuthState, bool>(
          selector: (state) => state.isBusy,
          builder: (context, isBusy) {
            return OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              onPressed: isBusy
                  ? null
                  : () => context.read<AuthCubit>().signInWithGoogle(),
              icon: const Icon(Icons.g_mobiledata, size: 32),
              label: const Text('Continue with Google'),
            );
          },
        ),
      ],
    );
  }
}
