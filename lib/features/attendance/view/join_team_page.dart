import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/firestore/team_repository.dart';
import '../bloc/join_team_bloc.dart';
import 'join_team_view.dart';

class JoinTeamPage extends StatelessWidget {
  const JoinTeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => JoinTeamBloc(
        teamRepository: locate<TeamRepository>(),
      ),
      child: const JoinTeamView(),
    );
  }
}
