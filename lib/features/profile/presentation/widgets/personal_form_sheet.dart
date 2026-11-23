import 'package:flutter/material.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/validators/profile_validators.dart';
import 'profile_text_field.dart';

/// The editable personal fields, returned by [PersonalFormSheet].
typedef PersonalDetails = ({String fullName, String phone, String location});

/// Bottom sheet to edit name, phone and location of a saved profile.
class PersonalFormSheet extends StatefulWidget {
  const PersonalFormSheet({super.key, required this.profile});

  final UserProfile profile;

  @override
  State<PersonalFormSheet> createState() => _PersonalFormSheetState();
}

class _PersonalFormSheetState extends State<PersonalFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _location;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profile.fullName);
    _phone = TextEditingController(text: widget.profile.phone);
    _location = TextEditingController(text: widget.profile.location);
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _location.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(
      context,
    ).pop((fullName: _name.text, phone: _phone.text, location: _location.text));
  }

  @override
  Widget build(BuildContext context) {
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
                'Edit personal details',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ProfileTextField(
                controller: _name,
                label: 'Full name',
                icon: Icons.person_outline,
                keyboardType: TextInputType.name,
                validator: ProfileValidators.fullName,
              ),
              const SizedBox(height: 12),
              ProfileTextField(
                controller: _phone,
                label: 'Phone number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: ProfileValidators.phone,
              ),
              const SizedBox(height: 12),
              ProfileTextField(
                controller: _location,
                label: 'Town or city',
                icon: Icons.location_on_outlined,
                textInputAction: TextInputAction.done,
                validator: ProfileValidators.location,
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
