import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/auth/auth_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_bloc.dart';
import '../bloc/profile_bloc.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profiel')),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listenWhen: (prev, curr) =>
            prev.updateStatus != curr.updateStatus,
        listener: (context, state) {
          if (state.updateStatus == ProfileUpdateStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage ?? 'Opgeslagen!')),
            );
          } else if (state.updateStatus == ProfileUpdateStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Er ging iets mis.')),
            );
          }
        },
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              const SizedBox(height: AppSpacing.lg),
              // Avatar with photo picker
              Center(
                child: GestureDetector(
                  onTap: () => _showPhotoOptions(context),
                  child: Stack(
                    children: [
                      CircleAvatar(
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
                      if (state.isUploadingPhoto)
                        Positioned.fill(
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.black38,
                            child: const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      else
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
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
              const SizedBox(height: AppSpacing.xxl),

              // Settings
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.edit_outlined),
                      title: const Text('Naam wijzigen'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showNameDialog(context, state.displayName),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.lock_outline),
                      title: const Text('Wachtwoord wijzigen'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showPasswordDialog(context),
                    ),
                    const Divider(height: 1),
                    BlocBuilder<ThemeBloc, ThemeState>(
                      builder: (context, themeState) {
                        return ListTile(
                          leading: const Icon(Icons.dark_mode_outlined),
                          title: const Text('Donker thema'),
                          trailing: Switch(
                            value: themeState.themeMode == ThemeMode.dark,
                            onChanged: (_) => context
                                .read<ThemeBloc>()
                                .add(const ThemeToggled()),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Logout
              FilledButton.icon(
                onPressed: () => _showLogoutDialog(context),
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

  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galerij'),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(context, ImageSource.gallery);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPhoto(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (picked != null && context.mounted) {
      context
          .read<ProfileBloc>()
          .add(ProfilePhotoChanged(photo: File(picked.path)));
    }
  }

  void _showNameDialog(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Naam wijzigen'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Naam'),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuleren'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                context
                    .read<ProfileBloc>()
                    .add(ProfileNameChanged(name: name));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Opslaan'),
          ),
        ],
      ),
    );
  }

  void _showPasswordDialog(BuildContext context) {
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Wachtwoord wijzigen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Nieuw wachtwoord'),
              obscureText: true,
              autofocus: true,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: confirmController,
              decoration:
                  const InputDecoration(labelText: 'Bevestig wachtwoord'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuleren'),
          ),
          FilledButton(
            onPressed: () {
              final password = passwordController.text;
              final confirm = confirmController.text;
              if (password.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Wachtwoord moet minimaal 6 tekens zijn.'),
                  ),
                );
                return;
              }
              if (password != confirm) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Wachtwoorden komen niet overeen.'),
                  ),
                );
                return;
              }
              context
                  .read<ProfileBloc>()
                  .add(ProfilePasswordChanged(newPassword: password));
              Navigator.pop(ctx);
            },
            child: const Text('Wijzigen'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Uitloggen'),
        content: const Text('Weet je zeker dat je wilt uitloggen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuleren'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            child: const Text('Uitloggen'),
          ),
        ],
      ),
    );
  }
}
