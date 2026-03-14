import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/firestore/checklist_repository.dart';
import '../../../core/models/checklist.dart';

part 'bardienst_event.dart';
part 'bardienst_state.dart';

class BardienstBloc extends Bloc<BardienstEvent, BardienstState> {
  BardienstBloc({required ChecklistRepository checklistRepository})
      : _checklistRepository = checklistRepository,
        super(const BardienstState()) {
    on<BardienstLoadRequested>(_onLoadRequested);
    on<BardienstChecklistDeleted>(_onChecklistDeleted);
  }

  final ChecklistRepository _checklistRepository;

  Future<void> _onLoadRequested(
    BardienstLoadRequested event,
    Emitter<BardienstState> emit,
  ) {
    emit(state.copyWith(status: BardienstStatus.loading));
    return emit.forEach<List<Checklist>>(
      _checklistRepository.checklists(event.ownerUid),
      onData: (checklists) => state.copyWith(
        status: BardienstStatus.loaded,
        checklists: checklists,
      ),
      onError: (_, _) => state.copyWith(status: BardienstStatus.failure),
    );
  }

  Future<void> _onChecklistDeleted(
    BardienstChecklistDeleted event,
    Emitter<BardienstState> emit,
  ) async {
    await _checklistRepository.deleteChecklist(event.id);
  }
}
