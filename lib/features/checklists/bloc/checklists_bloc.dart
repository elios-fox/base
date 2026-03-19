import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/firestore/checklist_repository.dart';
import '../../../core/models/checklist.dart';

part 'checklists_event.dart';
part 'checklists_state.dart';

class ChecklistsBloc extends Bloc<ChecklistsEvent, ChecklistsState> {
  ChecklistsBloc({required ChecklistRepository checklistRepository})
      : _checklistRepository = checklistRepository,
        super(const ChecklistsState()) {
    on<ChecklistsLoadRequested>(_onLoadRequested);
    on<ChecklistsChecklistDeleted>(_onChecklistDeleted);
  }

  final ChecklistRepository _checklistRepository;

  Future<void> _onLoadRequested(
    ChecklistsLoadRequested event,
    Emitter<ChecklistsState> emit,
  ) {
    emit(state.copyWith(status: ChecklistsStatus.loading));
    return emit.forEach<List<Checklist>>(
      _checklistRepository.checklists(event.ownerUid),
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
    await _checklistRepository.deleteChecklist(event.id);
  }
}
