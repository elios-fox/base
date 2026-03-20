import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../services/event_service.dart';
import '../../../services/team_service.dart';
import '../bloc/home_bloc.dart';
import 'home_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final wrapper = SupabaseClientWrapper.instance;
    return BlocProvider(
      create: (_) => HomeBloc(
        teamService: locate<TeamService>(),
        eventService: locate<EventService>(),
        userId: wrapper.userId,
        displayName: wrapper.userDisplayName,
      )..add(const HomeStarted()),
      child: const HomeView(),
    );
  }
}
