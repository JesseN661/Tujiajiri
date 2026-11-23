import 'package:flutter/material.dart';

import '../../domain/entities/education.dart';
import '../../domain/entities/experience.dart';
import '../../domain/entities/user_profile.dart';
import 'education_form_sheet.dart';
import 'experience_form_sheet.dart';
import 'personal_form_sheet.dart';

// Shared openers, so onboarding and the profile page use the same forms.

Future<Education?> showEducationSheet(
  BuildContext context, {
  required String id,
  Education? initial,
}) => showModalBottomSheet<Education>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => EducationFormSheet(id: id, initial: initial),
);

Future<Experience?> showExperienceSheet(
  BuildContext context, {
  required String id,
  Experience? initial,
}) => showModalBottomSheet<Experience>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => ExperienceFormSheet(id: id, initial: initial),
);

Future<PersonalDetails?> showPersonalSheet(
  BuildContext context, {
  required UserProfile profile,
}) => showModalBottomSheet<PersonalDetails>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => PersonalFormSheet(profile: profile),
);

/// Asks before deleting saved data; true means the user confirmed.
Future<bool> confirmRemove(BuildContext context, String what) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Remove $what?'),
      content: const Text('This cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Remove'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
