import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tujiajiri/features/applications/domain/entities/application_status.dart';
import 'package:tujiajiri/features/applications/domain/entities/job_application.dart';

import '../bloc/applications_state.dart';
import '../bloc/employer_applications_cubit.dart';
import '../widgets/status_chip.dart';

/// Applications received by the signed-in employer, with status actions.
/// Needs an [EmployerApplicationsCubit] above it in the tree.
class EmployerApplicationsPage extends StatefulWidget {
  const EmployerApplicationsPage({super.key});

  @override
  State<EmployerApplicationsPage> createState() =>
      _EmployerApplicationsPageState();
}

class _EmployerApplicationsPageState extends State<EmployerApplicationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<EmployerApplicationsCubit>().watch();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EmployerApplicationsCubit, ApplicationsState>(
      listenWhen: (previous, current) =>
          previous.feedbackId != current.feedbackId,
      listener: (context, state) {
        final message = state.message;
        if (message == null) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      },
      child: BlocBuilder<EmployerApplicationsCubit, ApplicationsState>(
        builder: (context, state) {
          switch (state.status) {
            case ApplicationsStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case ApplicationsStatus.failure:
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Could not load received applications.'),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () =>
                          context.read<EmployerApplicationsCubit>().watch(),
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              );
            case ApplicationsStatus.loaded:
              if (state.applications.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No applications received yet.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.applications.length,
                itemBuilder: (context, index) =>
                    _ReceivedCard(application: state.applications[index]),
              );
          }
        },
      ),
    );
  }
}

class _ReceivedCard extends StatelessWidget {
  const _ReceivedCard({required this.application});

  final JobApplication application;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final date = application.appliedAt;
    final options = application.status.nextOptions;
    final title = application.jobTitle.isEmpty
        ? 'Job application'
        : application.jobTitle;
    final applicantId = application.applicantId;
    final shortId = applicantId.length > 6
        ? applicantId.substring(0, 6)
        : applicantId;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Applicant $shortId · '
                    '${date.day}/${date.month}/${date.year}',
                    style: textTheme.bodySmall,
                  ),
                  if (application.coverLetter.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      application.coverLetter,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: 8),
                  StatusChip(status: application.status),
                ],
              ),
            ),
            PopupMenuButton<ApplicationStatus>(
              tooltip: 'Change status',
              enabled: options.isNotEmpty,
              onSelected: (next) => context
                  .read<EmployerApplicationsCubit>()
                  .updateStatus(application, next),
              itemBuilder: (_) => [
                for (final option in options)
                  PopupMenuItem(value: option, child: Text(option.label)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
