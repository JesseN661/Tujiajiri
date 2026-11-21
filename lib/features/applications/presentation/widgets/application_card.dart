import 'package:flutter/material.dart';
import 'package:tujiajiri/features/applications/domain/entities/job_application.dart';

import 'status_chip.dart';

class ApplicationCard extends StatelessWidget {
  const ApplicationCard({
    super.key,
    required this.application,
    required this.jobTitle,
    this.onWithdraw,
  });

  final JobApplication application;
  final String jobTitle;

  /// Null when the application can no longer be withdrawn.
  final VoidCallback? onWithdraw;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final date = application.appliedAt;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    jobTitle,
                    style: textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Applied ${date.day}/${date.month}/${date.year}',
                    style: textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  StatusChip(status: application.status),
                ],
              ),
            ),
            if (onWithdraw != null)
              IconButton(
                tooltip: 'Withdraw application',
                icon: const Icon(Icons.close),
                onPressed: onWithdraw,
              ),
          ],
        ),
      ),
    );
  }
}
