import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/education.dart';
import '../../domain/validators/profile_validators.dart';
import 'profile_text_field.dart';

/// Bottom sheet to add or edit one education entry; pops the result.
class EducationFormSheet extends StatefulWidget {
  const EducationFormSheet({super.key, required this.id, this.initial});

  final String id;
  final Education? initial;

  @override
  State<EducationFormSheet> createState() => _EducationFormSheetState();
}

class _EducationFormSheetState extends State<EducationFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _school;
  late final TextEditingController _degree;
  late final TextEditingController _field;
  late final TextEditingController _start;
  late final TextEditingController _end;

  @override
  void initState() {
    super.initState();
    final item = widget.initial;
    _school = TextEditingController(text: item?.school ?? '');
    _degree = TextEditingController(text: item?.degree ?? '');
    _field = TextEditingController(text: item?.fieldOfStudy ?? '');
    _start = TextEditingController(text: item?.startYear.toString() ?? '');
    _end = TextEditingController(text: item?.endYear?.toString() ?? '');
  }

  @override
  void dispose() {
    _school.dispose();
    _degree.dispose();
    _field.dispose();
    _start.dispose();
    _end.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final end = _end.text.trim();
    Navigator.of(context).pop(
      Education(
        id: widget.id,
        school: _school.text.trim(),
        degree: _degree.text.trim(),
        fieldOfStudy: _field.text.trim(),
        startYear: int.parse(_start.text.trim()),
        endYear: end.isEmpty ? null : int.parse(end),
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
                widget.initial == null ? 'Add education' : 'Edit education',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ProfileTextField(
                controller: _school,
                label: 'School or institution',
                icon: Icons.school_outlined,
                validator: ProfileValidators.school,
              ),
              const SizedBox(height: 12),
              ProfileTextField(
                controller: _degree,
                label: 'Qualification',
                helperText: 'For example: Diploma, Certificate, Secondary',
                validator: ProfileValidators.degree,
              ),
              const SizedBox(height: 12),
              ProfileTextField(
                controller: _field,
                label: 'Field of study (optional)',
                validator: ProfileValidators.fieldOfStudy,
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
                helperText: 'Leave empty if you are still studying here',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: years,
                validator: (value) =>
                    ProfileValidators.endYear(value, _start.text),
              ),
              const SizedBox(height: 20),
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
