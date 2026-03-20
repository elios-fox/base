import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../attendance/widgets/event_card.dart';
import '../../attendance/widgets/team_card.dart';
import '../bloc/home_bloc.dart';
import '../widgets/home_greeting_card.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ClubHub')),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return switch (state.status) {
            HomeStatus.initial ||
            HomeStatus.loading =>
              const LoadingIndicator(),
            HomeStatus.success => _HomeContent(state: state),
            HomeStatus.failure => ErrorView(
                message: 'Er ging iets mis.',
                onRetry: () =>
                    context.read<HomeBloc>().add(const HomeStarted()),
              ),
          };
        },
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        HomeGreetingCard(greeting: state.greeting),
        const SizedBox(height: AppSpacing.xl),

        // Upcoming events
        Text(
          'Komende events',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (state.upcomingEvents.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Icon(
                    Icons.event_available,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'Geen komende events',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...state.upcomingEvents.map(
            (event) => EventCard(
              event: event,
              onTap: () => context.push(
                '/attendance/${event.teamId}/event/${event.id}',
                extra: event,
              ),
            ),
          ),

        const SizedBox(height: AppSpacing.xl),

        // My teams
        Row(
          children: [
            Text(
              'Mijn teams',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.goNamed(RouteNames.attendance),
              child: const Text('Alle teams'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (state.teams.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Icon(
                    Icons.groups_outlined,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Je zit nog in geen team. Ga naar Teams om een team aan te maken of te joinen.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...state.teams.map(
            (team) => TeamCard(
              team: team,
              onTap: () => context.goNamed(
                RouteNames.teamEvents,
                pathParameters: {'teamId': team.id},
                queryParameters: {'name': team.name},
              ),
            ),
          ),

        const SizedBox(height: AppSpacing.xl),

        // Quick actions
        Text(
          'Snelkoppelingen',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.sports,
                label: 'Mijn club',
                onTap: () => context.push('/clubs'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.newspaper,
                label: 'Nieuws',
                onTap: () => context.push('/news'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.checklist,
                label: 'Checklists',
                onTap: () => context.push('/checklists'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.lg,
            horizontal: AppSpacing.sm,
          ),
          child: Column(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                style: theme.textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
