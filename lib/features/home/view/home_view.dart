import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
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
            HomeStatus.success => _HomeContent(greeting: state.greeting),
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
  const _HomeContent({required this.greeting});

  final String greeting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        HomeGreetingCard(greeting: greeting),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Komende events',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              'Geen komende events',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Mijn teams',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              'Geen teams',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
}