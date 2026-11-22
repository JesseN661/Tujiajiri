import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/applications_cubit.dart';

/// Lets the signed-in user apply for a job. Needs an [ApplicationsCubit]
/// above the app's Navigator.
class ApplyPage extends StatefulWidget {
  const ApplyPage({
    super.key,
    required this.jobId,
    required this.jobTitle,
    required this.employerId,
    required this.employerName,
  });

  final String jobId;
  final String jobTitle;
  final String employerId;
  final String employerName;

  @override
  State<ApplyPage> createState() => _ApplyPageState();
}

class _ApplyPageState extends State<ApplyPage> {
  static const _maxLength = 1000;

  final _coverLetter = TextEditingController();
  final _submitting = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _coverLetter.dispose();
    _submitting.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final cubit = context.read<ApplicationsCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    _submitting.value = true;
    final error = await cubit.submit(
      jobId: widget.jobId,
      employerId: widget.employerId,
      jobTitle: widget.jobTitle,
      employerName: widget.employerName,
      coverLetter: _coverLetter.text,
    );
    if (!mounted) return;
    _submitting.value = false;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(error ?? 'Application submitted.')),
      );
    if (error == null) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Apply')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.jobTitle, style: textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(widget.employerName, style: textTheme.titleMedium),
              const SizedBox(height: 24),
              TextField(
                controller: _coverLetter,
                maxLines: 6,
                maxLength: _maxLength,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Cover letter (optional)',
                  hintText: 'Tell the employer why you are a good fit',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<bool>(
                valueListenable: _submitting,
                builder: (context, submitting, _) => SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: submitting ? null : _submit,
                    child: submitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit application'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
