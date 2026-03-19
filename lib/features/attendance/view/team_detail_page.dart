import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../services/team_service.dart';
import '../bloc/team_detail_bloc.dart';
import 'team_detail_view.dart';

class TeamDetailPage extends StatelessWidget {
  const TeamDetailPage({super.key, required this.teamId});

  final String teamId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TeamDetailBloc(
        teamService: locate<TeamService>(),
      )..add(TeamDetailLoadRequested(teamId)),
      child: const TeamDetailView(),
    );
  }
}
