import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/validators/profile_validators.dart';
import '../bloc/onboarding_cubit.dart';
import 'profile_text_field.dart';
import 'step_navigation.dart';

/// Step 1: name, phone and location.
class PersonalStep extends StatefulWidget {
  const PersonalStep({super.key});

  @override
  State<PersonalStep> createState() => _PersonalStepState();
}

class _PersonalStepState extends State<PersonalStep> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _location;

  @override
  void initState() {
    super.initState();
    // Start from saved values so Back from step 2 keeps what was typed.
    final state = context.read<OnboardingCubit>().state;
    _name = TextEditingController(text: state.fullName);
    _phone = TextEditingController(text: state.phone);
    _location = TextEditingController(text: state.location);
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _location.dispose();
    super.dispose();
  }

  void _next() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<OnboardingCubit>().submitPersonal(
      fullName: _name.text,
      phone: _phone.text,
      location: _location.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Personal details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            const Text('Employers use these to contact you.'),
            const SizedBox(height: 20),
            ProfileTextField(
              controller: _name,
              label: 'Full name',
              icon: Icons.person_outline,
              keyboardType: TextInputType.name,
              validator: ProfileValidators.fullName,
            ),
            const SizedBox(height: 16),
            ProfileTextField(
              controller: _phone,
              label: 'Phone number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: ProfileValidators.phone,
            ),
            const SizedBox(height: 16),
            ProfileTextField(
              controller: _location,
              label: 'Town or city',
              icon: Icons.location_on_outlined,
              textInputAction: TextInputAction.done,
              validator: ProfileValidators.location,
            ),
            const SizedBox(height: 28),
            StepNavigation(nextLabel: 'Next', onNext: _next),
          ],
        ),
      ),
    );
  }
}
