import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/checklist.dart';
import '../../../services/checklist_service.dart';

part 'checklists_event.dart';
part 'checklists_state.dart';

class ChecklistsBloc extends Bloc<ChecklistsEvent, ChecklistsState> {
  ChecklistsBloc({required ChecklistService checklistService})
      : _checklistService = checklistService,
        super(const ChecklistsState()) {
    on<ChecklistsLoadRequested>(_onLoadRequested);
    on<ChecklistsChecklistDeleted>(_onChecklistDeleted);
  }

  final ChecklistService _checklistService;

  Future<void> _onLoadRequested(
    ChecklistsLoadRequested event,
    Emitter<ChecklistsState> emit,
  ) {
    emit(state.copyWith(status: ChecklistsStatus.loading));
    return emit.forEach<List<Checklist>>(
      _checklistService.getChecklists(event.ownerUid),
      onData: (checklists) => state.copyWith(
        status: ChecklistsStatus.loaded,
        checklists: checklists,
      ),
      onError: (_, _) => state.copyWith(status: ChecklistsStatus.failure),
    );
  }

  Future<void> _onChecklistDeleted(
    ChecklistsChecklistDeleted event,
    Emitter<ChecklistsState> emit,
  ) async {
    await _checklistService.deleteChecklist(event.id);
  }
}
