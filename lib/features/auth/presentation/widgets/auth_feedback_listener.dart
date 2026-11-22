import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';

/// Shows each new [AuthState.message] as a snackbar (red for errors).
class AuthFeedbackListener extends StatelessWidget {
  const AuthFeedbackListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      // feedbackId changes per message, so repeats still show.
      listenWhen: (previous, current) =>
          previous.feedbackId != current.feedbackId,
      listener: (context, state) {
        final message = state.message;
        if (message == null) return;
        final scheme = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                message,
                style: TextStyle(color: state.isError ? scheme.onError : null),
              ),
              backgroundColor: state.isError ? scheme.error : null,
            ),
          );
      },
      child: child,
    );
  }
}
