import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/auth/domain/entities/app_user.dart';
import '../features/auth/presentation/bloc/auth_cubit.dart';
import '../features/profile/domain/repositories/user_profile_repository.dart';
import '../features/profile/presentation/bloc/onboarding_cubit.dart';
import '../features/profile/presentation/bloc/onboarding_state.dart';
import '../features/profile/presentation/pages/onboarding_page.dart';
import 'splash_page.dart';

/// For a signed-in, verified user: shows onboarding until the profile is
/// saved in Firestore, then shows the app's main screen via [readyBuilder].
class ProfileGate extends StatelessWidget {
  const ProfileGate({
    super.key,
    required this.user,
    required this.readyBuilder,
  });

  final AppUser user;
  final WidgetBuilder readyBuilder;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OnboardingCubit>(
      // A new account gets a fresh cubit instead of the previous user's data.
      key: ValueKey(user.uid),
      create: (context) => OnboardingCubit(
        repository: context.read<UserProfileRepository>(),
        user: user,
      )..load(),
      child: BlocBuilder<OnboardingCubit, OnboardingState>(
        buildWhen: (previous, current) => previous.status != current.status,
        builder: (context, state) {
          return switch (state.status) {
            OnboardingStatus.loading => const SplashPage(),
            OnboardingStatus.loadFailed => _LoadFailedView(
              onRetry: () => context.read<OnboardingCubit>().load(),
            ),
            OnboardingStatus.inProgress => const OnboardingPage(),
            OnboardingStatus.ready => readyBuilder(context),
          };
        },
      ),
    );
  }
}

/// Shown when the profile could not be read (offline or no permission).
class _LoadFailedView extends StatelessWidget {
  const _LoadFailedView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 56),
                const SizedBox(height: 16),
                Text(
                  'We could not load your profile.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Check your internet connection and try again.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: onRetry,
                  child: const Text('Try again'),
                ),
                TextButton(
                  onPressed: () => context.read<AuthCubit>().signOut(),
                  child: const Text('Log out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
