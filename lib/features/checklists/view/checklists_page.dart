import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/auth/auth_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../services/checklist_service.dart';
import '../bloc/checklists_bloc.dart';
import 'checklists_view.dart';

class ChecklistsPage extends StatelessWidget {
  const ChecklistsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthBloc>().state.user!.uid;
    return BlocProvider(
      create: (_) => ChecklistsBloc(
        checklistService: locate<ChecklistService>(),
      )..add(ChecklistsLoadRequested(ownerUid: uid)),
      child: const ChecklistsView(),
    );
  }
}
