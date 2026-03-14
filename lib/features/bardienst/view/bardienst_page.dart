import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/auth/auth_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../core/firestore/checklist_repository.dart';
import '../bloc/bardienst_bloc.dart';
import 'bardienst_view.dart';

class BardienstPage extends StatelessWidget {
  const BardienstPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthBloc>().state.user!.uid;
    return BlocProvider(
      create: (_) => BardienstBloc(
        checklistRepository: locate<ChecklistRepository>(),
      )..add(BardienstLoadRequested(ownerUid: uid)),
      child: const BardienstView(),
    );
  }
}
