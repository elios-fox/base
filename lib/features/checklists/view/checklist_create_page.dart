import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/auth/auth_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../core/firestore/checklist_repository.dart';
import '../../../core/storage/storage_repository.dart';
import '../bloc/checklist_create_bloc.dart';
import 'checklist_create_view.dart';

class ChecklistCreatePage extends StatelessWidget {
  const ChecklistCreatePage({super.key, this.checklistId});

  final String? checklistId;

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthBloc>().state.user!.uid;
    return BlocProvider(
      create: (_) => ChecklistCreateBloc(
        checklistRepository: locate<ChecklistRepository>(),
        storageRepository: locate<StorageRepository>(),
        ownerUid: uid,
      )..add(ChecklistCreateStarted(existingId: checklistId)),
      child: const ChecklistCreateView(),
    );
  }
}
