import 'package:flutter/material.dart';
import 'package:tujiajiri/features/applications/domain/entities/application_status.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final ApplicationStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (background, foreground) = switch (status) {
      ApplicationStatus.submitted => (
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
      ),
      ApplicationStatus.underReview => (
        scheme.tertiaryContainer,
        scheme.onTertiaryContainer,
      ),
      ApplicationStatus.accepted => (
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
      ),
      ApplicationStatus.rejected => (
        scheme.errorContainer,
        scheme.onErrorContainer,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: foreground),
      ),
    );
  }
}
