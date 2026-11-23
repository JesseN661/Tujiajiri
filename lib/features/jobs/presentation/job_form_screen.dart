import 'package:flutter/material.dart';

import '../../../core/presentation/snackbars.dart';
import '../data/job_repository.dart';
import '../domain/entities/job.dart';

/// Lets an employer post a new job, or edit one when [job] is given.
class JobFormScreen extends StatefulWidget {
  const JobFormScreen({
    super.key,
    this.job,
    required this.employerId,
    required this.employerName,
    this.repository,
  });

  final Job? job;
  final String employerId;
  final String employerName;
  final JobRepository? repository;

  @override
  State<JobFormScreen> createState() => _JobFormScreenState();
}

class _JobFormScreenState extends State<JobFormScreen> {
  static const List<String> employmentTypes = [
    'Internship',
    'Full-time',
    'Part-time',
    'Contract',
  ];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _location;
  late final TextEditingController _experienceLevel;
  late final TextEditingController _skills;
  late String _employmentType;

  bool get _isEditing => widget.job != null;

  @override
  void initState() {
    super.initState();
    final job = widget.job;
    _title = TextEditingController(text: job?.title ?? '');
    _description = TextEditingController(text: job?.description ?? '');
    _location = TextEditingController(text: job?.location ?? '');
    _experienceLevel = TextEditingController(text: job?.experienceLevel ?? '');
    _skills = TextEditingController(text: job?.requiredSkills.join(', ') ?? '');
    _employmentType = employmentTypes.contains(job?.employmentType)
        ? job!.employmentType
        : employmentTypes.first;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _location.dispose();
    _experienceLevel.dispose();
    _skills.dispose();
    super.dispose();
  }

  String? _required(String? value) =>
      (value == null || value.trim().isEmpty) ? 'Required' : null;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final repository = widget.repository ?? JobRepository();
    final data = {
      'title': _title.text.trim(),
      'description': _description.text.trim(),
      'location': _location.text.trim(),
      'employmentType': _employmentType,
      'experienceLevel': _experienceLevel.text.trim(),
      'requiredSkills': _skills.text
          .split(',')
          .map((skill) => skill.trim())
          .where((skill) => skill.isNotEmpty)
          .toList(),
    };

    try {
      if (_isEditing) {
        await repository.updateJob(widget.job!.id, data);
      } else {
        await repository.createJob({
          ...data,
          'employerId': widget.employerId,
          'employerName': widget.employerName,
          'isVerified': false,
          'status': 'published',
        });
      }
      if (!mounted) return;
      context.showMessage(_isEditing ? 'Job updated.' : 'Job posted.');
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (error) {
      if (mounted) context.showError(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Job' : 'Post a Job')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Job title'),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 4,
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _location,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: _required,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _employmentType,
                decoration: const InputDecoration(labelText: 'Employment type'),
                items: employmentTypes
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                onChanged: (value) =>
                    _employmentType = value ?? _employmentType,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _experienceLevel,
                decoration: const InputDecoration(
                  labelText: 'Experience level',
                  hintText: 'e.g. Entry level',
                ),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _skills,
                decoration: const InputDecoration(
                  labelText: 'Required skills',
                  hintText: 'Separate with commas',
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _save,
                child: Text(_isEditing ? 'Save changes' : 'Post job'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
