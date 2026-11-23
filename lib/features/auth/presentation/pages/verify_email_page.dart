import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_submit_button.dart';

/// Shown to email/password users until they open the verification link.
class VerifyEmailPage extends StatelessWidget {
  const VerifyEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final email = context.select((AuthCubit cubit) => cubit.state.user?.email);

    return AuthScaffold(
      title: 'Verify your email',
      children: [
        Icon(
          Icons.mark_email_unread_outlined,
          size: 64,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Check your inbox',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Text(
          'We sent a verification link to ${email ?? 'your email'}. '
          'Open it, then come back and tap the button below.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 28),
        AuthSubmitButton(
          label: 'I have verified my email',
          onPressed: () => context.read<AuthCubit>().refreshVerification(),
        ),
        const SizedBox(height: 12),
        BlocSelector<AuthCubit, AuthState, bool>(
          selector: (state) => state.isBusy,
          builder: (context, isBusy) {
            return OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              onPressed: isBusy
                  ? null
                  : () => context.read<AuthCubit>().resendVerificationEmail(),
              child: const Text('Resend email'),
            );
          },
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => context.read<AuthCubit>().signOut(),
          child: const Text('Use a different account'),
        ),
      ],
    );
  }
}
