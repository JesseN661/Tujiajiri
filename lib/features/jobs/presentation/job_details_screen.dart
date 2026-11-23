import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/snackbars.dart';
import '../../applications/presentation/pages/apply_page.dart';
import '../../auth/presentation/bloc/auth_cubit.dart';
import '../data/job_repository.dart';
import '../domain/entities/job.dart';
import 'job_form_screen.dart';

class JobDetailsScreen extends StatelessWidget {
  final Job job;
  final JobRepository? repository;

  const JobDetailsScreen({super.key, required this.job, this.repository});

  void _edit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobFormScreen(
          job: job,
          employerId: job.employerId,
          employerName: job.employerName,
          repository: repository,
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this job?'),
        content: const Text('Seekers will no longer see it.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await (repository ?? JobRepository()).deleteJob(job.id);
      if (!context.mounted) return;
      context.showMessage('Job deleted.');
      Navigator.pop(context);
    } catch (error) {
      if (context.mounted) context.showError(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthCubit>().state.user?.uid;
    final isOwner = uid != null && uid == job.employerId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        actions: [
          if (isOwner) ...[
            IconButton(
              tooltip: 'Edit job',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _edit(context),
            ),
            IconButton(
              tooltip: 'Delete job',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _delete(context),
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title,
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    job.employerName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),

                  _infoRow(Icons.location_on_outlined, job.location),
                  _infoRow(Icons.work_outline, job.employmentType),
                  _infoRow(Icons.school_outlined, job.experienceLevel),

                  if (job.isVerified) ...[
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Icon(Icons.verified, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Verified employer'),
                      ],
                    ),
                  ],

                  const SizedBox(height: 28),

                  Text(
                    'Job Description',
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    job.description.isEmpty
                        ? 'No description provided yet.'
                        : job.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),

                  const SizedBox(height: 28),

                  Text(
                    'Required Skills',
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  if (job.requiredSkills.isEmpty)
                    const Text('No specific skills listed.')
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: job.requiredSkills.map((skill) {
                        return Chip(label: Text(skill));
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),

          if (!isOwner)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ApplyPage(
                            jobId: job.id,
                            jobTitle: job.title,
                            employerId: job.employerId,
                            employerName: job.employerName,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.send_outlined),
                    label: const Text('Apply Now'),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
