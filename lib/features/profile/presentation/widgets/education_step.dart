import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/education.dart';
import '../bloc/onboarding_cubit.dart';
import '../bloc/onboarding_state.dart';
import 'entry_card.dart';
import 'entry_sheets.dart';
import 'step_navigation.dart';

/// Step 2: add, edit and remove education entries (optional).
class EducationStep extends StatelessWidget {
  const EducationStep({super.key});

  Future<void> _openForm(BuildContext context, [Education? initial]) async {
    final cubit = context.read<OnboardingCubit>();
    final result = await showEducationSheet(
      context,
      id: initial?.id ?? cubit.newId(),
      initial: initial,
    );
    if (result != null) cubit.saveEducation(result);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();
    return BlocSelector<OnboardingCubit, OnboardingState, List<Education>>(
      selector: (state) => state.education,
      builder: (context, items) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Education', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              const Text('Add your schools or courses. You can skip this.'),
              const SizedBox(height: 20),
              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'No education added yet.',
                    textAlign: TextAlign.center,
                  ),
                ),
              for (final item in items)
                EntryCard(
                  title: item.fieldOfStudy.isEmpty
                      ? item.degree
                      : '${item.degree} in ${item.fieldOfStudy}',
                  subtitle:
                      '${item.school}  |  '
                      '${formatYearRange(item.startYear, item.endYear)}',
                  onEdit: () => _openForm(context, item),
                  onDelete: () => cubit.removeEducation(item.id),
                ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                onPressed: () => _openForm(context),
                icon: const Icon(Icons.add),
                label: const Text('Add education'),
              ),
              const SizedBox(height: 28),
              StepNavigation(
                nextLabel: 'Next',
                onBack: () => cubit.goToStep(OnboardingStep.personal),
                onNext: () => cubit.goToStep(OnboardingStep.experience),
              ),
            ],
          ),
        );
      },
    );
  }
}
