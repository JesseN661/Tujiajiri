import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../bloc/onboarding_cubit.dart';
import '../bloc/onboarding_state.dart';
import '../widgets/education_step.dart';
import '../widgets/experience_step.dart';
import '../widgets/personal_step.dart';

/// Three-step onboarding: personal details, education, experience.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  static const _titles = {
    OnboardingStep.personal: 'Personal details',
    OnboardingStep.education: 'Education',
    OnboardingStep.experience: 'Experience',
  };

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingCubit, OnboardingState>(
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
              content: Text(message, style: TextStyle(color: scheme.onError)),
              backgroundColor: scheme.error,
            ),
          );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Set up your profile'),
          actions: [
            TextButton(
              onPressed: () => context.read<AuthCubit>().signOut(),
              child: const Text('Log out'),
            ),
          ],
        ),
        body: Column(
          children: [
            BlocSelector<OnboardingCubit, OnboardingState, OnboardingStep>(
              selector: (state) => state.step,
              builder: (context, step) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: (step.index + 1) / OnboardingStep.values.length,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                      child: Text(
                        'Step ${step.index + 1} of '
                        '${OnboardingStep.values.length}: ${_titles[step]}',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ],
                );
              },
            ),
            Expanded(
              child: SafeArea(
                top: false,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child:
                        BlocSelector<
                          OnboardingCubit,
                          OnboardingState,
                          OnboardingStep
                        >(
                          selector: (state) => state.step,
                          builder: (context, step) => switch (step) {
                            OnboardingStep.personal => const PersonalStep(),
                            OnboardingStep.education => const EducationStep(),
                            OnboardingStep.experience => const ExperienceStep(),
                          },
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
