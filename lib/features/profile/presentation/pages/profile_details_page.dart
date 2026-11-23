import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../domain/entities/education.dart';
import '../../domain/entities/experience.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../bloc/profile_cubit.dart';
import '../bloc/profile_state.dart';
import '../widgets/entry_card.dart';
import '../widgets/entry_section.dart';
import '../widgets/entry_sheets.dart';
import '../widgets/personal_card.dart';

/// Shows the saved profile and lets the user edit, add and remove entries.
/// Every change is written to Firestore and appears here straight away.
class ProfileDetailsPage extends StatelessWidget {
  const ProfileDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileCubit>(
      create: (context) => ProfileCubit(
        repository: context.read<UserProfileRepository>(),
        uid: context.read<AuthCubit>().state.user?.uid ?? '',
      )..start(),
      child: const _ProfileDetailsView(),
    );
  }
}

class _ProfileDetailsView extends StatelessWidget {
  const _ProfileDetailsView();

  Future<void> _editPersonal(BuildContext context) async {
    final cubit = context.read<ProfileCubit>();
    final profile = cubit.state.profile;
    if (profile == null) return;
    final result = await showPersonalSheet(context, profile: profile);
    if (result == null) return;
    await cubit.updatePersonal(
      fullName: result.fullName,
      phone: result.phone,
      location: result.location,
    );
  }

  Future<void> _editEducation(BuildContext context, [Education? item]) async {
    final cubit = context.read<ProfileCubit>();
    final result = await showEducationSheet(
      context,
      id: item?.id ?? cubit.newId(),
      initial: item,
    );
    if (result != null) await cubit.saveEducation(result);
  }

  Future<void> _removeEducation(BuildContext context, Education item) async {
    final cubit = context.read<ProfileCubit>();
    if (await confirmRemove(context, 'this education')) {
      await cubit.deleteEducation(item.id);
    }
  }

  Future<void> _editExperience(BuildContext context, [Experience? item]) async {
    final cubit = context.read<ProfileCubit>();
    final result = await showExperienceSheet(
      context,
      id: item?.id ?? cubit.newId(),
      initial: item,
    );
    if (result != null) await cubit.saveExperience(result);
  }

  Future<void> _removeExperience(BuildContext context, Experience item) async {
    final cubit = context.read<ProfileCubit>();
    if (await confirmRemove(context, 'this experience')) {
      await cubit.deleteExperience(item.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
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
      child: Scaffold(
        appBar: AppBar(title: const Text('Profile details')),
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            final profile = state.profile;
            if (state.status == ProfileStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == ProfileStatus.failure || profile == null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('We could not load your profile.'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => context.read<ProfileCubit>().start(),
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              );
            }
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    PersonalCard(
                      profile: profile,
                      onEdit: () => _editPersonal(context),
                    ),
                    EntrySection(
                      title: 'Education',
                      addLabel: 'Add education',
                      emptyText: 'No education added yet.',
                      onAdd: () => _editEducation(context),
                      children: [
                        for (final item in state.education)
                          EntryCard(
                            title: item.fieldOfStudy.isEmpty
                                ? item.degree
                                : '${item.degree} in ${item.fieldOfStudy}',
                            subtitle:
                                '${item.school}  |  '
                                '${formatYearRange(item.startYear, item.endYear)}',
                            onEdit: () => _editEducation(context, item),
                            onDelete: () => _removeEducation(context, item),
                          ),
                      ],
                    ),
                    EntrySection(
                      title: 'Experience',
                      addLabel: 'Add experience',
                      emptyText: 'No experience added yet.',
                      onAdd: () => _editExperience(context),
                      children: [
                        for (final item in state.experience)
                          EntryCard(
                            title: item.role,
                            subtitle:
                                '${item.company}  |  '
                                '${formatYearRange(item.startYear, item.endYear)}',
                            onEdit: () => _editExperience(context, item),
                            onDelete: () => _removeExperience(context, item),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
