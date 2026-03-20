import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../bloc/standings_bloc.dart';
import '../widgets/result_card.dart';
import '../widgets/standings_table.dart';

class StandingsView extends StatelessWidget {
  const StandingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Competitiestand')),
      body: BlocBuilder<StandingsBloc, StandingsState>(
        builder: (context, state) {
          return switch (state.status) {
            StandingsStatus.initial ||
            StandingsStatus.loading =>
              const LoadingIndicator(),
            StandingsStatus.failure => ErrorView(
                message: 'Kon de stand niet laden.',
                onRetry: () {
                  if (state.teamId != null) {
                    context
                        .read<StandingsBloc>()
                        .add(StandingsLoadRequested(teamId: state.teamId!));
                  }
                },
              ),
            StandingsStatus.loaded => state.matchResults.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Nog geen uitslagen ingevoerd.\n'
                        'Voer een uitslag in bij een wedstrijd.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : _StandingsContent(state: state),
          };
        },
      ),
    );
  }
}

class _StandingsContent extends StatelessWidget {
  const _StandingsContent({required this.state});

  final StandingsState state;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stand tabel
          Text(
            'Stand',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          StandingsTable(standings: state.standings),
          const SizedBox(height: 24),

          // Recente uitslagen
          Text(
            'Recente uitslagen',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ...state.matchResults.map(
            (result) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ResultCard(
                result: result,
                onDelete: () {
                  context
                      .read<StandingsBloc>()
                      .add(ResultDeleted(id: result.id));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
