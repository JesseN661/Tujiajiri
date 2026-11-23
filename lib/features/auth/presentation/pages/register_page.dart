import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/validators/auth_validators.dart';
import '../bloc/auth_cubit.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_submit_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/google_sign_in_button.dart';

/// Sign-up with name, email and a confirmed password.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthCubit>().register(
      name: _name.text,
      email: _email.text,
      password: _password.text,
      confirmation: _confirmation.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Create account',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              AuthTextField(
                controller: _name,
                label: 'Full name',
                icon: Icons.person_outline,
                keyboardType: TextInputType.name,
                autofillHints: const [AutofillHints.name],
                validator: AuthValidators.name,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _email,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                validator: AuthValidators.email,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _password,
                label: 'Password',
                icon: Icons.lock_outline,
                isPassword: true,
                helperText:
                    'At least 8 characters, with a letter and a number.',
                autofillHints: const [AutofillHints.newPassword],
                validator: AuthValidators.newPassword,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _confirmation,
                label: 'Confirm password',
                icon: Icons.lock_outline,
                isPassword: true,
                textInputAction: TextInputAction.done,
                validator: (value) =>
                    AuthValidators.confirmPassword(_password.text, value),
                onSubmitted: _submit,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        AuthSubmitButton(label: 'Create account', onPressed: _submit),
        const SizedBox(height: 20),
        const GoogleSignInButton(),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('I already have an account'),
        ),
      ],
    );
  }
}
