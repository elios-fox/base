import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../bloc/club_bloc.dart';
import '../widgets/club_card.dart';

class ClubListView extends StatelessWidget {
  const ClubListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mijn clubs')),
      body: BlocConsumer<ClubBloc, ClubState>(
        listenWhen: (prev, curr) =>
            prev.createStatus != curr.createStatus,
        listener: (context, state) {
          if (state.createStatus == ClubCreateStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Gelukt!')),
            );
          } else if (state.createStatus == ClubCreateStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Er ging iets mis.'),
              ),
            );
          }
        },
        builder: (context, state) {
          return switch (state.status) {
            ClubStatus.initial || ClubStatus.loading => const LoadingIndicator(),
            ClubStatus.failure => ErrorView(
                message: 'Kon clubs niet laden.',
                onRetry: () =>
                    context.read<ClubBloc>().add(const ClubLoadRequested()),
              ),
            ClubStatus.loaded => state.clubs.isEmpty
                ? _EmptyState(onCreateClub: () => _showCreateDialog(context))
                : _ClubList(clubs: state.clubs),
          };
        },
      ),
      floatingActionButton: BlocBuilder<ClubBloc, ClubState>(
        builder: (context, state) {
          if (state.status != ClubStatus.loaded) return const SizedBox.shrink();
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.small(
                heroTag: 'join_club',
                onPressed: () => _showJoinDialog(context),
                child: const Icon(Icons.link),
              ),
              const SizedBox(height: AppSpacing.sm),
              FloatingActionButton(
                heroTag: 'create_club',
                onPressed: () => _showCreateDialog(context),
                child: const Icon(Icons.add),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Club aanmaken'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Clubnaam',
            hintText: 'Bijv. SC Oranje',
          ),
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
                    .read<ClubBloc>()
                    .add(ClubCreateRequested(name: name));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Aanmaken'),
          ),
        ],
      ),
    );
  }

  void _showJoinDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Club joinen'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Uitnodigingscode',
            hintText: 'Voer de code in',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuleren'),
          ),
          FilledButton(
            onPressed: () {
              final code = controller.text.trim();
              if (code.isNotEmpty) {
                context
                    .read<ClubBloc>()
                    .add(ClubJoinRequested(inviteCode: code));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Joinen'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreateClub});
  final VoidCallback onCreateClub;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sports,
              size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Nog geen club',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Maak een club aan of join een bestaande club met een uitnodigingscode.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: onCreateClub,
              icon: const Icon(Icons.add),
              label: const Text('Club aanmaken'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClubList extends StatelessWidget {
  const _ClubList({required this.clubs});
  final List clubs;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: clubs.length,
      itemBuilder: (context, index) {
        final club = clubs[index];
        return ClubCard(
          club: club,
          onTap: () => context.goNamed(
            RouteNames.clubDetail,
            pathParameters: {'clubId': club.id},
          ),
        );
      },
    );
  }
}
