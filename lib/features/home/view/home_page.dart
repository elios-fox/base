import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../core/models/team.dart';
import '../../../core/models/team_event.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../services/team_service.dart';
import '../../../services/event_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Team> _teams = [];
  List<TeamEvent> _events = [];
  bool _loading = true;
  StreamSubscription<List<Team>>? _teamSub;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final uid = context.read<AuthBloc>().state.user?.uid;
    if (uid == null) return;

    _teamSub = locate<TeamService>().getTeams(uid).listen((teams) {
      if (mounted) setState(() { _teams = teams; _loading = false; });
    });

    locate<EventService>().getUpcomingEvents(uid).then((events) {
      if (mounted) setState(() => _events = events);
    }).catchError((_) {});
  }

  @override
  void dispose() { _teamSub?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<AuthBloc>().state.user;
    final initial = (user?.displayName ?? '?').isNotEmpty ? (user?.displayName ?? '?')[0].toUpperCase() : '?';

    return Scaffold(
      body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(AppSpacing.lg), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('ClubHub', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          GestureDetector(onTap: () => context.go('/profile'), child: CircleAvatar(radius: 20, backgroundColor: AppColors.primary,
            backgroundImage: user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
            child: user?.photoUrl == null ? Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)) : null)),
        ]),
        const SizedBox(height: AppSpacing.xl),

        // Teams
        if (_loading)
          const Center(child: Padding(padding: EdgeInsets.all(AppSpacing.xxl), child: CircularProgressIndicator()))
        else if (_teams.isEmpty) ...[
          Card(child: InkWell(borderRadius: AppSpacing.borderRadiusMd, onTap: () => context.push('/team/create'), child: Padding(padding: const EdgeInsets.all(AppSpacing.lg), child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Team toevoegen', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSpacing.xs),
              Text('Maak een nieuw team aan', style: TextStyle(color: AppColors.grey)),
            ])),
            Container(width: 44, height: 44, decoration: BoxDecoration(border: Border.all(color: AppColors.divider), borderRadius: AppSpacing.borderRadiusSm), child: const Icon(Icons.add)),
          ])))),
          const SizedBox(height: AppSpacing.sm),
          Card(child: InkWell(borderRadius: AppSpacing.borderRadiusMd, onTap: () => context.go('/teams'), child: Padding(padding: const EdgeInsets.all(AppSpacing.lg), child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Team joinen', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSpacing.xs),
              Text('Voer een teamcode in', style: TextStyle(color: AppColors.grey)),
            ])),
            Container(width: 44, height: 44, decoration: BoxDecoration(border: Border.all(color: AppColors.divider), borderRadius: AppSpacing.borderRadiusSm), child: const Icon(Icons.group_add_outlined)),
          ])))),
        ] else ...[
          // Team kaarten
          ..._teams.map((team) => Padding(padding: const EdgeInsets.only(bottom: AppSpacing.sm), child: Card(child: ListTile(
            leading: CircleAvatar(backgroundColor: AppColors.primary,
              backgroundImage: team.photoUrl != null ? NetworkImage(team.photoUrl!) : null,
              child: team.photoUrl == null ? Text(team.name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)) : null),
            title: Text(team.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('${team.sport ?? ''} · ${team.memberUids.length} leden'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/teams/${team.id}'),
          )))),
        ],
        const SizedBox(height: AppSpacing.lg),

        // Evenementen
        Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppSpacing.radiusSm)), child: const Text('Evenement', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
        const SizedBox(height: AppSpacing.sm),
        if (_events.isEmpty)
          Padding(padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl), child: Center(child: Column(children: [
            Icon(Icons.event_outlined, size: 48, color: AppColors.greyLight),
            const SizedBox(height: AppSpacing.sm),
            Text('Nog geen evenementen', style: TextStyle(color: AppColors.grey)),
          ])))
        else
          ..._events.map((e) => Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ListTile(
              leading: Icon(e.isWedstrijd ? Icons.emoji_events_outlined : Icons.fitness_center_outlined, color: e.isWedstrijd ? AppColors.wedstrijd : AppColors.training),
              title: Text(e.title, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(_formatDate(e.dateTime)),
              onTap: () {
                final team = _teams.where((t) => t.id == e.teamId).firstOrNull;
                if (team != null) context.push('/teams/${team.id}/event/${e.id}', extra: e);
              },
            ),
          )),
      ]))),
    );
  }

  String _formatDate(DateTime dt) {
    const days = ['ma', 'di', 'wo', 'do', 'vr', 'za', 'zo'];
    const months = ['jan', 'feb', 'mrt', 'apr', 'mei', 'jun', 'jul', 'aug', 'sep', 'okt', 'nov', 'dec'];
    return '${days[dt.weekday - 1]} ${dt.day} ${months[dt.month - 1]} · ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
