import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/experience.dart';
import '../bloc/onboarding_cubit.dart';
import '../bloc/onboarding_state.dart';
import 'entry_card.dart';
import 'entry_sheets.dart';
import 'step_navigation.dart';

/// Step 3: add, edit and remove work experience (optional), then finish.
class ExperienceStep extends StatelessWidget {
  const ExperienceStep({super.key});

  Future<void> _openForm(BuildContext context, [Experience? initial]) async {
    final cubit = context.read<OnboardingCubit>();
    final result = await showExperienceSheet(
      context,
      id: initial?.id ?? cubit.newId(),
      initial: initial,
    );
    if (result != null) cubit.saveExperience(result);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      buildWhen: (previous, current) =>
          previous.experience != current.experience ||
          previous.isSaving != current.isSaving,
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Experience', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              const Text('Add jobs or placements you have done. Optional.'),
              const SizedBox(height: 20),
              if (state.experience.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'No experience added yet.',
                    textAlign: TextAlign.center,
                  ),
                ),
              for (final item in state.experience)
                EntryCard(
                  title: item.role,
                  subtitle:
                      '${item.company}  |  '
                      '${formatYearRange(item.startYear, item.endYear)}',
                  onEdit: () => _openForm(context, item),
                  onDelete: () => cubit.removeExperience(item.id),
                ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                onPressed: state.isSaving ? null : () => _openForm(context),
                icon: const Icon(Icons.add),
                label: const Text('Add experience'),
              ),
              const SizedBox(height: 28),
              StepNavigation(
                nextLabel: 'Finish',
                isBusy: state.isSaving,
                onBack: () => cubit.goToStep(OnboardingStep.education),
                onNext: cubit.finish,
              ),
            ],
          ),
        );
      },
    );
  }
}
