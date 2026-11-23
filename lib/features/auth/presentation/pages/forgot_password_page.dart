import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/validators/auth_validators.dart';
import '../bloc/auth_cubit.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_submit_button.dart';
import '../widgets/auth_text_field.dart';

/// Asks for an email and sends a password reset link.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final navigator = Navigator.of(context);
    final sent = await context.read<AuthCubit>().sendPasswordReset(_email.text);
    // Go back to login once the link was sent; stay to fix errors otherwise.
    if (sent && mounted) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Reset password',
      children: [
        Text(
          'Enter the email you registered with and we will send you a link '
          'to choose a new password.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        Form(
          key: _formKey,
          child: AuthTextField(
            controller: _email,
            label: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            validator: AuthValidators.email,
            onSubmitted: _submit,
          ),
        ),
        const SizedBox(height: 24),
        AuthSubmitButton(label: 'Send reset link', onPressed: _submit),
      ],
    );
  }
}
