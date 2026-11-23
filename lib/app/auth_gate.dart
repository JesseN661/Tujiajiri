import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/auth/presentation/bloc/auth_cubit.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/verify_email_page.dart';
import 'profile_gate.dart';
import 'splash_page.dart';

/// Chooses the screen from the auth state: login, verify email, onboarding,
/// or the main screen ([homeBuilder]). Firebase restores the saved session,
/// so a returning user goes straight past login.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.homeBuilder});

  final WidgetBuilder homeBuilder;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      // Close pushed pages (register, profile...) when the session changes.
      listener: (context, state) =>
          Navigator.of(context).popUntil((route) => route.isFirst),
      child: BlocBuilder<AuthCubit, AuthState>(
        buildWhen: (previous, current) =>
            previous.status != current.status ||
            previous.user?.uid != current.user?.uid,
        builder: (context, state) {
          final user = state.user;
          return switch (state.status) {
            AuthStatus.unknown => const SplashPage(),
            AuthStatus.unauthenticated => const LoginPage(),
            AuthStatus.needsVerification => const VerifyEmailPage(),
            AuthStatus.authenticated when user != null => ProfileGate(
              user: user,
              readyBuilder: homeBuilder,
            ),
            AuthStatus.authenticated => const SplashPage(),
          };
        },
      ),
    );
  }
}
