import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../bloc/login_bloc.dart';
import '../widgets/auth_card.dart';
import '../widgets/email_password_form.dart';
import '../widgets/social_sign_in_button.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

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
      },
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: AuthCard(
              children: [
                Text(
                  'Welkom',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Log in om verder te gaan',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                EmailPasswordForm(
                  submitLabel: 'Inloggen',
                  onSubmitted: () => context
                      .read<LoginBloc>()
                      .add(const LoginWithEmailSubmitted()),
                ),
                const SizedBox(height: 24),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('of'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),
                BlocBuilder<LoginBloc, LoginState>(
                  buildWhen: (previous, current) =>
                      previous.status != current.status,
                  builder: (context, state) {
                    final isSubmitting =
                        state.status == LoginStatus.submitting;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SocialSignInButton(
                          label: 'Doorgaan met Google',
                          icon: const Icon(Icons.g_mobiledata, size: 24),
                          onPressed: isSubmitting
                              ? null
                              : () => context
                                  .read<LoginBloc>()
                                  .add(const LoginWithGooglePressed()),
                        ),
                        const SizedBox(height: 8),
                        SocialSignInButton(
                          label: 'Doorgaan met Apple',
                          icon: const Icon(Icons.apple, size: 20),
                          onPressed: isSubmitting
                              ? null
                              : () => context
                                  .read<LoginBloc>()
                                  .add(const LoginWithApplePressed()),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => context.goNamed(RouteNames.signUp),
                  child: const Text('Geen account? Registreer je'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
