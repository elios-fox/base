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
      body: BlocListener<TeamListBloc, TeamListState>(
        listenWhen: (previous, current) =>
            current.errorMessage != null &&
            current.errorMessage != previous.errorMessage,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        child: BlocBuilder<TeamListBloc, TeamListState>(
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
      ),
    );
  }

  static const _sportOptions = [
    'Voetbal',
    'Padel',
    'Tennis',
    'Squash',
    'Waterpolo',
    'Hockey',
    'Handbal',
    'Basketbal',
    'Volleybal',
    'Rugby',
    'Atletiek',
    'Zwemmen',
    'Boulderen',
    'Overig',
  ];

  void _showCreateTeamDialog(BuildContext context) {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? selectedSport;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocConsumer<TeamListBloc, TeamListState>(
          listenWhen: (previous, current) =>
              previous.isCreating && !current.isCreating,
          listener: (context, state) {
            if (state.errorMessage == null) {
              // Create succeeded — close dialog
              Navigator.of(dialogContext).pop();
            }
          },
          builder: (context, state) {
            return AlertDialog(
              title: const Text('Nieuw team'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Teamnaam',
                        hintText: 'bijv. Heren 1',
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vul een teamnaam in';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedSport,
                      decoration: const InputDecoration(
                        labelText: 'Sport',
                      ),
                      items: _sportOptions
                          .map((sport) => DropdownMenuItem(
                                value: sport,
                                child: Text(sport),
                              ))
                          .toList(),
                      onChanged: (value) => selectedSport = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kies een sport';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: state.isCreating
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Annuleren'),
                ),
                FilledButton(
                  onPressed: state.isCreating
                      ? null
                      : () {
                          if (formKey.currentState!.validate()) {
                            final uid =
                                context.read<AuthBloc>().state.user!.uid;
                            context.read<TeamListBloc>().add(
                                  TeamCreateRequested(
                                    name: nameController.text.trim(),
                                    ownerUid: uid,
                                    sport: selectedSport ?? '',
                                  ),
                                );
                          }
                        },
                  child: state.isCreating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Aanmaken'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}