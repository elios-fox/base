import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/login_bloc.dart';

class EmailPasswordForm extends StatelessWidget {
  const EmailPasswordForm({
    super.key,
    required this.submitLabel,
    required this.onSubmitted,
    this.showConfirmPassword = false,
  });

  final String submitLabel;
  final VoidCallback onSubmitted;
  final bool showConfirmPassword;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              key: const Key('emailField'),
              onChanged: (email) =>
                  context.read<LoginBloc>().add(LoginEmailChanged(email)),
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-mailadres',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('passwordField'),
              onChanged: (password) =>
                  context.read<LoginBloc>().add(LoginPasswordChanged(password)),
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Wachtwoord',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outlined),
              ),
            ),
            if (showConfirmPassword) ...[
              const SizedBox(height: 16),
              TextField(
                key: const Key('confirmPasswordField'),
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Bevestig wachtwoord',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outlined),
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (state.status == LoginStatus.failure &&
                state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  state.errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            FilledButton(
              key: const Key('submitButton'),
              onPressed:
                  state.status == LoginStatus.submitting ? null : onSubmitted,
              child: state.status == LoginStatus.submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(submitLabel),
            ),
          ],
        );
      },
    );
  }
}
