import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../services/club_service.dart';
import '../bloc/club_bloc.dart';
import 'club_list_view.dart';

class ClubListPage extends StatelessWidget {
  const ClubListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ClubBloc(
        clubService: locate<ClubService>(),
        userId: SupabaseClientWrapper.instance.userId,
      )..add(const ClubLoadRequested()),
      child: const ClubListView(),
    );
  }
}
