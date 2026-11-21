import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tujiajiri/features/applications/domain/entities/job_application.dart';

import '../bloc/applications_cubit.dart';
import '../bloc/applications_state.dart';
import '../widgets/application_card.dart';

/// The Tracker tab. Expects an [ApplicationsCubit] above it in the tree.
class ApplicationsPage extends StatelessWidget {
  const ApplicationsPage({super.key, required this.jobTitleFor});

  /// Supplied by the jobs feature later (job title for a job id).
  final String Function(String jobId) jobTitleFor;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ApplicationsCubit, ApplicationsState>(
      listenWhen: (previous, current) =>
          previous.feedbackId != current.feedbackId,
      listener: (context, state) {
        final message = state.message;
        if (message == null) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      },
      child: BlocBuilder<ApplicationsCubit, ApplicationsState>(
        builder: (context, state) {
          switch (state.status) {
            case ApplicationsStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case ApplicationsStatus.failure:
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Could not load your applications.'),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () =>
                          context.read<ApplicationsCubit>().watch(),
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
                      'No applications yet. Apply for a job and track it here.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return Column(
                children: [
                  _SummaryRow(state: state),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: state.applications.length,
                      itemBuilder: (context, index) {
                        final application = state.applications[index];
                        final title = jobTitleFor(application.jobId);
                        return ApplicationCard(
                          application: application,
                          jobTitle: title,
                          onWithdraw: application.status.isFinal
                              ? null
                              : () => _confirmWithdraw(
                                  context,
                                  application,
                                  title,
                                ),
                        );
                      },
                    ),
                  ),
                ],
              );
          }
        },
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.state});

  final ApplicationsState state;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleSmall;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('In progress: ${state.inProgressCount}', style: style),
          Text('Decided: ${state.decidedCount}', style: style),
        ],
      ),
    );
  }
}

Future<void> _confirmWithdraw(
  BuildContext context,
  JobApplication application,
  String title,
) async {
  final cubit = context.read<ApplicationsCubit>();
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Withdraw application?'),
      content: Text('Your application for $title will be removed.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Withdraw'),
        ),
      ],
    ),
  );
  if (confirmed == true) {
    await cubit.withdraw(application);
  }
}
