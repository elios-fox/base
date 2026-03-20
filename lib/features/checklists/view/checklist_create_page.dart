import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/auth/auth_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../core/supabase/supabase_storage.dart';
import '../../../services/checklist_service.dart';
import '../bloc/checklist_create_bloc.dart';
import 'checklist_create_view.dart';

class ChecklistCreatePage extends StatelessWidget {
  const ChecklistCreatePage({super.key, this.checklistId, this.teamId});

  final String? checklistId;
  final String? teamId;

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthBloc>().state.user!.uid;
    return BlocProvider(
      create: (_) => ChecklistCreateBloc(
        checklistService: locate<ChecklistService>(),
        storageService: locate<StorageService>(),
        ownerUid: uid,
        teamId: teamId,
      )..add(ChecklistCreateStarted(existingId: checklistId)),
      child: const ChecklistCreateView(),
    );
  }
}
