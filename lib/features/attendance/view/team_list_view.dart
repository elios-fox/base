import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../bloc/team_list_bloc.dart';
import '../widgets/team_card.dart';

class TeamListView extends StatelessWidget {
  const TeamListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teams')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateTeamDialog(context),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<TeamListBloc, TeamListState>(
        builder: (context, state) {
          return switch (state.status) {
            TeamListStatus.initial ||
            TeamListStatus.loading =>
              const LoadingIndicator(),
            TeamListStatus.failure => ErrorView(
                message: 'Kon teams niet laden.',
                onRetry: () {
                  final uid = context.read<AuthBloc>().state.user!.uid;
                  context
                      .read<TeamListBloc>()
                      .add(TeamListLoadRequested(userUid: uid));
                },
              ),
            TeamListStatus.loaded => state.teams.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.groups_outlined, size: 64, color: AppColors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Nog geen teams.',
                            style: TextStyle(fontSize: 18, color: AppColors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Maak een team aan om de aanwezigheid bij te houden.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.teams.length,
                    itemBuilder: (context, index) {
                      final team = state.teams[index];
                      return TeamCard(
                        team: team,
                        onTap: () => context.go('/attendance/${team.id}'),
                        onDelete: () {
                          context
                              .read<TeamListBloc>()
                              .add(TeamDeleteRequested(team.id));
                        },
                      );
                    },
                  ),
          };
        },
      ),
    );
  }

  void _showCreateTeamDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Nieuw team'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Teamnaam',
              hintText: 'bijv. Heren 1',
            ),
            textCapitalization: TextCapitalization.words,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annuleren'),
            ),
            FilledButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  final uid = context.read<AuthBloc>().state.user!.uid;
                  context.read<TeamListBloc>().add(
                        TeamCreateRequested(name: name, ownerUid: uid),
                      );
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Aanmaken'),
            ),
          ],
        );
      },
    );
  }
}