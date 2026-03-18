import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/firestore/team_repository.dart';
import '../bloc/event_list_bloc.dart';
import 'team_events_view.dart';

class TeamEventsPage extends StatelessWidget {
  const TeamEventsPage({
    super.key,
    required this.teamId,
    required this.teamName,
  });

  final String teamId;
  final String teamName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EventListBloc(
        teamRepository: locate<TeamRepository>(),
      )..add(EventListLoadRequested(teamId: teamId)),
      child: TeamEventsView(teamId: teamId, teamName: teamName),
    );
  }
}