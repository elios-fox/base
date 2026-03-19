import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/auth/auth_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/profile_bloc.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profiel')),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 16),
              // Avatar
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  backgroundImage: state.photoUrl != null
                      ? NetworkImage(state.photoUrl!)
                      : null,
                  child: state.photoUrl == null
                      ? Icon(
                          Icons.person,
                          size: 48,
                          color: theme.colorScheme.onPrimaryContainer,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  state.displayName,
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              Center(
                child: Text(
                  state.email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Settings
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.edit_outlined),
                      title: const Text('Naam wijzigen'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO: implement
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.lock_outline),
                      title: const Text('Wachtwoord wijzigen'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO: implement
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.dark_mode_outlined),
                      title: const Text('Donker thema'),
                      trailing: Switch(
                        value: Theme.of(context).brightness == Brightness.dark,
                        onChanged: (_) {
                          // TODO: implement theme toggle
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Logout
              FilledButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Uitloggen'),
                      content:
                          const Text('Weet je zeker dat je wilt uitloggen?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Annuleren'),
                        ),
                        FilledButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            context
                                .read<AuthBloc>()
                                .add(const AuthLogoutRequested());
                          },
                          child: const Text('Uitloggen'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Uitloggen'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
