import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/firestore/team_repository.dart';
import '../bloc/team_detail_bloc.dart';
import 'team_detail_view.dart';

class TeamDetailPage extends StatelessWidget {
  const TeamDetailPage({super.key, required this.teamId});

  final String teamId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TeamDetailBloc(
        teamRepository: locate<TeamRepository>(),
      )..add(TeamDetailLoadRequested(teamId)),
      child: const TeamDetailView(),
    );
  }
}
