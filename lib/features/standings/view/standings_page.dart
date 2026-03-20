import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../services/standings_service.dart';
import '../bloc/standings_bloc.dart';
import 'standings_view.dart';

class StandingsPage extends StatelessWidget {
  const StandingsPage({super.key, required this.teamId});

  final String teamId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StandingsBloc(
        standingsService: locate<StandingsService>(),
      )..add(StandingsLoadRequested(teamId: teamId)),
      child: const StandingsView(),
    );
  }
}
