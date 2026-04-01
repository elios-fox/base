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

class TeamDetailPage extends StatefulWidget {
  const TeamDetailPage({super.key, required this.teamId});
  final String teamId;
  @override
  State<TeamDetailPage> createState() => _TeamDetailPageState();
}

class _TeamDetailPageState extends State<TeamDetailPage> {
  Team? _team;
  List<TeamEvent> _events = [];
  bool _loading = true;
  StreamSubscription<List<TeamEvent>>? _eventSub;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final team = await locate<TeamService>().getTeam(widget.teamId);
    if (mounted) setState(() { _team = team; _loading = false; });

    _eventSub = locate<EventService>().getEvents(widget.teamId).listen((events) {
      if (mounted) setState(() => _events = events);
    });
  }

  @override
  void dispose() { _eventSub?.cancel(); super.dispose(); }

  bool get _isOwner {
    final uid = context.read<AuthBloc>().state.user?.uid;
    return _team?.ownerUid == uid;
  }

  Future<void> _deleteTeam() async {
    final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Team verwijderen?'),
      content: Text('"${_team?.name}" en alle evenementen worden permanent verwijderd.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuleren')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), style: FilledButton.styleFrom(backgroundColor: AppColors.error), child: const Text('Verwijderen')),
      ],
    ));
    if (confirmed == true) {
      await locate<TeamService>().deleteTeam(widget.teamId);
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Team verwijderd'))); context.pop(); }
    }
  }

  Future<void> _leaveTeam() async {
    final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Team verlaten?'),
      content: Text('Je verlaat "${_team?.name}". Je kunt later opnieuw joinen met een teamcode.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuleren')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Verlaten')),
      ],
    ));
    if (confirmed == true) {
      final uid = context.read<AuthBloc>().state.user!.uid;
      await locate<TeamService>().leaveTeam(widget.teamId, uid);
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Team verlaten'))); context.pop(); }
    }
  }

  @override
  Widget build(BuildContext context) {
    
    if (_loading) return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    if (_team == null) return Scaffold(appBar: AppBar(), body: const Center(child: Text('Team niet gevonden')));

    final team = _team!;
    return Scaffold(
      appBar: AppBar(title: Text(team.name), actions: [
        PopupMenuButton<String>(
          onSelected: (v) { if (v == 'delete') _deleteTeam(); else if (v == 'leave') _leaveTeam(); },
          itemBuilder: (_) => _isOwner
            ? [const PopupMenuItem(value: 'delete', child: Text('Team verwijderen', style: TextStyle(color: AppColors.error)))]
            : [const PopupMenuItem(value: 'leave', child: Text('Team verlaten'))],
        ),
      ]),
      body: SingleChildScrollView(padding: const EdgeInsets.all(AppSpacing.lg), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // Banner
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: team.dominantColor != null ? Color(int.parse('FF${team.dominantColor}', radix: 16)) : AppColors.primary,
            borderRadius: AppSpacing.borderRadiusMd,
            image: team.photoUrl != null ? DecorationImage(image: NetworkImage(team.photoUrl!), fit: BoxFit.cover) : null,
          ),
          child: Padding(padding: const EdgeInsets.all(AppSpacing.lg), child: Column(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(team.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700, shadows: [Shadow(blurRadius: 8, color: Colors.black54)])),
            if (team.sport != null) Text(team.sport!, style: const TextStyle(color: Colors.white70, fontSize: 13, shadows: [Shadow(blurRadius: 8, color: Colors.black54)])),
          ])),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Evenementen
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs), decoration: BoxDecoration(color: AppColors.training, borderRadius: BorderRadius.circular(AppSpacing.radiusSm)), child: const Text('Evenement', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13))),
          if (_isOwner) IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => context.push('/teams/${widget.teamId}/event/create')),
        ]),
        const SizedBox(height: AppSpacing.sm),
        if (_events.isEmpty)
          Padding(padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl), child: Center(child: Text('Nog geen evenementen', style: TextStyle(color: AppColors.grey))))
        else
          ..._events.map((e) => Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ListTile(
              title: Text(e.title, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('${_formatDate(e.dateTime)} · ${e.type.name}'),
              trailing: Icon(e.isWedstrijd ? Icons.emoji_events_outlined : Icons.fitness_center_outlined, color: e.isWedstrijd ? AppColors.wedstrijd : AppColors.training),
              onTap: () => context.push('/teams/${widget.teamId}/event/${e.id}', extra: e),
            ),
          )),
        const SizedBox(height: AppSpacing.xl),

        // Leden
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs), decoration: BoxDecoration(color: AppColors.tertiary, borderRadius: BorderRadius.circular(AppSpacing.radiusSm)), child: Text('Leden (${team.memberUids.length})', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13))),
          if (_isOwner) IconButton(icon: const Icon(Icons.person_add_outlined), onPressed: () => context.push('/teams/${widget.teamId}/invite')),
        ]),
        const SizedBox(height: AppSpacing.sm),
        ...team.memberUids.map((uid) => ListTile(
          dense: true,
          leading: CircleAvatar(radius: 16, backgroundColor: AppColors.primary.withAlpha(50), child: Text(uid.substring(0, 1).toUpperCase(), style: TextStyle(fontSize: 12, color: AppColors.primary))),
          title: Text(uid == team.ownerUid ? 'Captain' : 'Lid', style: const TextStyle(fontSize: 13)),
          subtitle: Text(uid.substring(0, 8), style: TextStyle(fontSize: 11, color: AppColors.grey)),
        )),
      ])),
    );
  }

  String _formatDate(DateTime dt) {
    const days = ['ma', 'di', 'wo', 'do', 'vr', 'za', 'zo'];
    const months = ['jan', 'feb', 'mrt', 'apr', 'mei', 'jun', 'jul', 'aug', 'sep', 'okt', 'nov', 'dec'];
    return '${days[dt.weekday - 1]} ${dt.day} ${months[dt.month - 1]} · ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
