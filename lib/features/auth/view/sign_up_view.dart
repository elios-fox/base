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

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: AuthCard(
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
                onChanged: (name) =>
                    context.read<LoginBloc>().add(LoginNameChanged(name)),
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
          ),
        ),
      ),
    );
  }
}