import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../services/checklist_service.dart';
import '../bloc/checklist_run_bloc.dart';
import 'checklist_detail_view.dart';

class ChecklistDetailPage extends StatelessWidget {
  const ChecklistDetailPage({super.key, required this.checklistId});

  final String checklistId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = ChecklistRunBloc();
        _loadChecklist(bloc);
        return bloc;
      },
      child: const ChecklistDetailView(),
    );
  }

  Future<void> _loadChecklist(ChecklistRunBloc bloc) async {
    final service = locate<ChecklistService>();
    final checklist = await service.getChecklist(checklistId);
    if (checklist != null) {
      bloc.add(ChecklistRunStarted(checklist));
    }
  }
}
