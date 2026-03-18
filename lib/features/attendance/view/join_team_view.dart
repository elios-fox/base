import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_bloc.dart';
import '../bloc/join_team_bloc.dart';

class JoinTeamView extends StatelessWidget {
  const JoinTeamView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Team joinen')),
      body: BlocConsumer<JoinTeamBloc, JoinTeamState>(
        listener: (context, state) {
          if (state.status == JoinTeamStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Welkom bij ${state.teamName}!')),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.groups_outlined,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Voer de uitnodigingscode in die je van je coach hebt ontvangen.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                TextField(
                  autofocus: true,
                  textCapitalization: TextCapitalization.characters,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontFamily: 'monospace',
                    letterSpacing: 4,
                  ),
                  decoration: InputDecoration(
                    hintText: 'CODE',
                    errorText: state.status == JoinTeamStatus.failure
                        ? state.errorMessage
                        : null,
                  ),
                  onChanged: (value) => context
                      .read<JoinTeamBloc>()
                      .add(JoinTeamCodeChanged(value)),
                ),
                const SizedBox(height: 24),
                if (state.status == JoinTeamStatus.success)
                  Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.check_circle,
                              color: Colors.green, size: 48),
                          const SizedBox(height: 8),
                          Text(
                            'Welkom bij ${state.teamName}!',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          FilledButton(
                            onPressed: () => context.go('/attendance'),
                            child: const Text('Bekijk team'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: state.status == JoinTeamStatus.submitting
                          ? null
                          : () {
                              final uid =
                                  context.read<AuthBloc>().state.user!.uid;
                              context
                                  .read<JoinTeamBloc>()
                                  .add(JoinTeamSubmitted(userUid: uid));
                            },
                      child: state.status == JoinTeamStatus.submitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Deelnemen'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
