import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/auth/auth_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<AuthBloc>().state.user;
    final name = user?.displayName ?? '';
    final email = user?.email ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Scaffold(
      appBar: AppBar(title: const Text('Profiel')),
      body: ListView(children: [
        const SizedBox(height: AppSpacing.xl),
        Center(child: CircleAvatar(radius: 48, backgroundColor: AppColors.primary,
          backgroundImage: user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
          child: user?.photoUrl == null ? Text(initial, style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.w600)) : null)),
        const SizedBox(height: AppSpacing.lg),
        Center(child: Text(name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700))),
        Center(child: Text(email, style: TextStyle(color: AppColors.grey))),
        const SizedBox(height: AppSpacing.xxl),
        const Divider(height: 1),
        ListTile(leading: const Icon(Icons.lock_outlined), title: const Text('Wachtwoord wijzigen'), trailing: const Icon(Icons.chevron_right), onTap: () => context.push('/profile/password')),
        const Divider(height: 1),
        ListTile(leading: const Icon(Icons.notifications_outlined), title: const Text('Notificaties'), trailing: const Icon(Icons.chevron_right), onTap: () => context.push('/profile/notifications')),
        const Divider(height: 1),
        BlocBuilder<ThemeBloc, ThemeState>(builder: (context, ts) => SwitchListTile(secondary: const Icon(Icons.dark_mode_outlined), title: const Text('Dark mode'), value: ts.themeMode == ThemeMode.dark, onChanged: (_) => context.read<ThemeBloc>().add(const ThemeToggled()))),
        const Divider(height: 1),
        ListTile(leading: const Icon(Icons.logout, color: AppColors.afwezig), title: const Text('Uitloggen', style: TextStyle(color: AppColors.afwezig)), onTap: () => context.read<AuthBloc>().add(const AuthLogoutRequested())),
      ]),
    );
  }
}
