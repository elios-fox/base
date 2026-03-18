import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/auth/auth_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../core/firestore/team_repository.dart';
import '../bloc/team_list_bloc.dart';
import 'team_list_view.dart';

class TeamListPage extends StatelessWidget {
  const TeamListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthBloc>().state.user!.uid;
    return BlocProvider(
      create: (_) => TeamListBloc(
        teamRepository: locate<TeamRepository>(),
      )..add(TeamListLoadRequested(userUid: uid)),
      child: const TeamListView(),
    );
  }
}