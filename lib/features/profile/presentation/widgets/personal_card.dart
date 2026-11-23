import 'package:flutter/material.dart';

import '../../domain/entities/user_profile.dart';

/// Read-only summary of the personal details, with an edit button.
class PersonalCard extends StatelessWidget {
  const PersonalCard({super.key, required this.profile, required this.onEdit});

  final UserProfile profile;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.fullName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _row(Icons.email_outlined, profile.email),
                  _row(Icons.phone_outlined, profile.phone),
                  _row(Icons.location_on_outlined, profile.location),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Edit personal details',
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(value.isEmpty ? 'Not added' : value)),
        ],
      ),
    );
  }
}
