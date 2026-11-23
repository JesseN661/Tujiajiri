import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/experience.dart';
import '../../domain/validators/profile_validators.dart';
import 'profile_text_field.dart';

/// Bottom sheet to add or edit one work entry; pops the result.
class ExperienceFormSheet extends StatefulWidget {
  const ExperienceFormSheet({super.key, required this.id, this.initial});

  final String id;
  final Experience? initial;

  @override
  State<ExperienceFormSheet> createState() => _ExperienceFormSheetState();
}

class _ExperienceFormSheetState extends State<ExperienceFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _company;
  late final TextEditingController _role;
  late final TextEditingController _start;
  late final TextEditingController _end;
  late final TextEditingController _description;

  @override
  void initState() {
    super.initState();
    final item = widget.initial;
    _company = TextEditingController(text: item?.company ?? '');
    _role = TextEditingController(text: item?.role ?? '');
    _start = TextEditingController(text: item?.startYear.toString() ?? '');
    _end = TextEditingController(text: item?.endYear?.toString() ?? '');
    _description = TextEditingController(text: item?.description ?? '');
  }

  @override
  void dispose() {
    _company.dispose();
    _role.dispose();
    _start.dispose();
    _end.dispose();
    _description.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final end = _end.text.trim();
    Navigator.of(context).pop(
      Experience(
        id: widget.id,
        company: _company.text.trim(),
        role: _role.text.trim(),
        startYear: int.parse(_start.text.trim()),
        endYear: end.isEmpty ? null : int.parse(end),
        description: _description.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final years = [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(4),
    ];
    return Padding(
      // Lifts the form above the keyboard.
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.initial == null ? 'Add experience' : 'Edit experience',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ProfileTextField(
                controller: _company,
                label: 'Company or place',
                icon: Icons.business_outlined,
                validator: ProfileValidators.company,
              ),
              const SizedBox(height: 12),
              ProfileTextField(
                controller: _role,
                label: 'Job title',
                validator: ProfileValidators.role,
              ),
              const SizedBox(height: 12),
              ProfileTextField(
                controller: _start,
                label: 'Start year',
                keyboardType: TextInputType.number,
                inputFormatters: years,
                validator: ProfileValidators.startYear,
              ),
              const SizedBox(height: 12),
              ProfileTextField(
                controller: _end,
                label: 'End year (optional)',
                helperText: 'Leave empty if you still work here',
                keyboardType: TextInputType.number,
                inputFormatters: years,
                validator: (value) =>
                    ProfileValidators.endYear(value, _start.text),
              ),
              const SizedBox(height: 12),
              ProfileTextField(
                controller: _description,
                label: 'What did you do? (optional)',
                maxLines: 3,
                maxLength: 500,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                validator: ProfileValidators.description,
              ),
              const SizedBox(height: 12),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                onPressed: _save,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
