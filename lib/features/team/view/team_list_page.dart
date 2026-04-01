import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../core/models/team.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../services/team_service.dart';

class TeamListPage extends StatefulWidget {
  const TeamListPage({super.key});
  @override
  State<TeamListPage> createState() => _TeamListPageState();
}

class _TeamListPageState extends State<TeamListPage> {
  List<Team> _teams = [];
  bool _loading = true;
  StreamSubscription<List<Team>>? _sub;

  @override
  void initState() {
    super.initState();
    final uid = context.read<AuthBloc>().state.user?.uid;
    if (uid != null) {
      _sub = locate<TeamService>().getTeams(uid).listen((teams) {
        if (mounted) setState(() { _teams = teams; _loading = false; });
      }, onError: (_) {
        if (mounted) setState(() => _loading = false);
      });
    }
  }

  @override
  void dispose() { _sub?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uid = context.watch<AuthBloc>().state.user?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Teams'), actions: [
        IconButton(icon: const Icon(Icons.group_add_outlined), onPressed: () => context.push('/teams/join')),
      ]),
      floatingActionButton: FloatingActionButton(onPressed: () => context.push('/team/create'), child: const Icon(Icons.add)),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _teams.isEmpty
          ? Center(child: Padding(padding: const EdgeInsets.all(AppSpacing.xl), child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.groups_outlined, size: 64, color: AppColors.greyLight),
              const SizedBox(height: AppSpacing.lg),
              Text('Nog geen teams', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              Text('Maak een team aan of join er een.', style: TextStyle(color: AppColors.grey)),
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(onPressed: () => context.push('/team/create'), icon: const Icon(Icons.add), label: const Text('Team aanmaken')),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(onPressed: () => context.push('/teams/join'), icon: const Icon(Icons.qr_code), label: const Text('Team joinen')),
            ])))
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: _teams.length,
              separatorBuilder: (_, index) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (_, i) {
                final team = _teams[i];
                final isOwner = team.ownerUid == uid;
                return Card(child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: team.dominantColor != null ? Color(int.parse('FF${team.dominantColor}', radix: 16)) : AppColors.primary,
                    backgroundImage: team.photoUrl != null ? NetworkImage(team.photoUrl!) : null,
                    child: team.photoUrl == null ? Text(team.name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)) : null,
                  ),
                  title: Text(team.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${team.sport ?? 'Sport'} · ${team.memberUids.length} leden${isOwner ? ' · Captain' : ''}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/teams/${team.id}'),
                ));
              },
            ),
    );
  }
}
