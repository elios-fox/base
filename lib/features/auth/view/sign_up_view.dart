import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../bloc/login_bloc.dart';
import '../widgets/auth_card.dart';
import '../widgets/email_password_form.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<LoginBloc, LoginState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == LoginStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: theme.colorScheme.error,
              ),
            );
        }
        if (state.status == LoginStatus.emailConfirmationSent) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: const Text(
                  'We hebben een bevestigingsmail gestuurd. '
                  'Controleer je inbox om je account te activeren.',
                ),
                duration: const Duration(seconds: 6),
                backgroundColor: theme.colorScheme.primary,
              ),
            );
        }
      },
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: BlocBuilder<LoginBloc, LoginState>(
              buildWhen: (previous, current) =>
                  previous.status != current.status,
              builder: (context, state) {
                // Show a confirmation screen after email confirmation is sent.
                if (state.status == LoginStatus.emailConfirmationSent) {
                  return AuthCard(
                    children: [
                      Icon(
                        Icons.mark_email_read_outlined,
                        size: 64,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Controleer je inbox',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'We hebben een bevestigingsmail gestuurd naar '
                        '${state.email}. Klik op de link in de mail om je '
                        'account te activeren.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      FilledButton(
                        onPressed: () => context.goNamed(RouteNames.login),
                        child: const Text('Ga naar inloggen'),
                      ),
                    ],
                  );
                }

                return AuthCard(
                  children: [
                    Text(
                      'Account aanmaken',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Maak een account aan om te beginnen',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      key: const Key('nameField'),
                      onChanged: (name) => context
                          .read<LoginBloc>()
                          .add(LoginNameChanged(name)),
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Naam',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    EmailPasswordForm(
                      submitLabel: 'Registreren',
                      showConfirmPassword: true,
                      onSubmitted: () => context
                          .read<LoginBloc>()
                          .add(const SignUpWithEmailSubmitted()),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.goNamed(RouteNames.login),
                      child: const Text('Heb je al een account? Log in'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
