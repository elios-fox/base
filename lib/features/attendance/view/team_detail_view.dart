import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/auth/auth_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/color_utils.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../bloc/team_detail_bloc.dart';

class TeamDetailView extends StatelessWidget {
  const TeamDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Team')),
      body: BlocConsumer<TeamDetailBloc, TeamDetailState>(
        listener: (context, state) {
          if (state.codeCopied) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Code gekopieerd!')),
            );
          }
        },
        builder: (context, state) {
          return switch (state.status) {
            TeamDetailStatus.initial ||
            TeamDetailStatus.loading =>
              const LoadingIndicator(),
            TeamDetailStatus.failure => ErrorView(
                message: 'Kon team niet laden.',
                onRetry: () {},
              ),
            TeamDetailStatus.loaded => ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Team Photo Section
                  _TeamPhotoSection(
                    photoUrl: state.team!.photoUrl,
                    dominantColor: state.team!.dominantColor,
                    isOwner: context.read<AuthBloc>().state.user!.uid ==
                        state.team!.ownerUid,
                    isUploading: state.isUploadingPhoto,
                  ),
                  const SizedBox(height: 16),

                  // Team Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.team!.name,
                            style: theme.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          // Invite code
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.vpn_key_outlined, size: 20),
                                const SizedBox(width: 8),
                                const Text('Uitnodigingscode: '),
                                Text(
                                  state.team!.id,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 20),
                                  onPressed: () {
                                    context.read<TeamDetailBloc>().add(
                                          TeamDetailInviteCodeCopied(
                                              state.team!.id),
                                        );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Members
                  Text(
                    'Leden (${state.team!.memberUids.length})',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: state.team!.memberUids.map((uid) {
                        final isOwner = uid == state.team!.ownerUid;
                        final currentUid =
                            context.read<AuthBloc>().state.user!.uid;
                        final isCurrentUserOwner =
                            currentUid == state.team!.ownerUid;

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                theme.colorScheme.primaryContainer,
                            child: Icon(
                              isOwner ? Icons.star : Icons.person,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          title: Text(uid),
                          subtitle: Text(isOwner ? 'Coach' : 'Speler'),
                          trailing: isCurrentUserOwner && !isOwner
                              ? IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  color: AppColors.error,
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Lid verwijderen'),
                                        content: const Text(
                                          'Weet je zeker dat je dit lid wilt verwijderen?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx),
                                            child: const Text('Annuleren'),
                                          ),
                                          FilledButton(
                                            onPressed: () {
                                              context
                                                  .read<TeamDetailBloc>()
                                                  .add(
                                                    TeamDetailMemberRemoved(
                                                      teamId: state.team!.id,
                                                      memberUid: uid,
                                                    ),
                                                  );
                                              Navigator.pop(ctx);
                                            },
                                            child: const Text('Verwijderen'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                )
                              : null,
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Share button
                  OutlinedButton.icon(
                    onPressed: () {
                      context.read<TeamDetailBloc>().add(
                            TeamDetailInviteCodeCopied(state.team!.id),
                          );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Deel uitnodigingslink'),
                  ),
                ],
              ),
          };
        },
      ),
    );
  }
}

class _TeamPhotoSection extends StatelessWidget {
  const _TeamPhotoSection({
    required this.photoUrl,
    required this.dominantColor,
    required this.isOwner,
    required this.isUploading,
  });

  final String? photoUrl;
  final String? dominantColor;
  final bool isOwner;
  final bool isUploading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: isOwner && !isUploading ? () => _pickImage(context) : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 180,
          width: double.infinity,
          child: isUploading
              ? Container(
                  color: theme.colorScheme.surfaceContainerLow,
                  child: const Center(child: CircularProgressIndicator()),
                )
              : photoUrl != null
                  ? Image.network(
                      photoUrl!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _buildPlaceholder(theme),
                    )
                  : _buildPlaceholder(theme),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    final bgColor = dominantColor != null
        ? ColorUtils.hexToColor(dominantColor!).withValues(alpha: 0.15)
        : theme.colorScheme.surfaceContainerLow;
    final iconColor = dominantColor != null
        ? ColorUtils.hexToColor(dominantColor!)
        : theme.colorScheme.onSurfaceVariant;

    return Container(
      color: bgColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt_outlined, size: 48, color: iconColor),
          const SizedBox(height: 8),
          Text(
            isOwner ? 'Foto toevoegen' : 'Geen foto',
            style: theme.textTheme.bodyMedium?.copyWith(color: iconColor),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null && context.mounted) {
      context
          .read<TeamDetailBloc>()
          .add(TeamDetailPhotoUploadRequested(File(picked.path)));
    }
  }
}
