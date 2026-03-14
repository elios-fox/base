import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/firestore/checklist_repository.dart';
import '../bloc/checklist_wizard_bloc.dart';
import 'checklist_wizard_view.dart';

class ChecklistWizardPage extends StatelessWidget {
  const ChecklistWizardPage({super.key, required this.checklistId});

  final String checklistId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = ChecklistWizardBloc();
        _loadChecklist(bloc);
        return bloc;
      },
      child: const ChecklistWizardView(),
    );
  }

  Future<void> _loadChecklist(ChecklistWizardBloc bloc) async {
    final repo = locate<ChecklistRepository>();
    final checklist = await repo.getChecklist(checklistId);
    if (checklist != null) {
      bloc.add(ChecklistWizardStarted(checklist));
    }
  }
}
