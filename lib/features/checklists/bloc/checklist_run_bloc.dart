import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/checklist.dart';

part 'checklist_run_event.dart';
part 'checklist_run_state.dart';

class ChecklistRunBloc extends Bloc<ChecklistRunEvent, ChecklistRunState> {
  ChecklistRunBloc() : super(const ChecklistRunState()) {
    on<ChecklistRunStarted>(_onStarted);
    on<ChecklistRunItemToggled>(_onItemToggled);
  }

  void _onStarted(
    ChecklistRunStarted event,
    Emitter<ChecklistRunState> emit,
  ) {
    emit(ChecklistRunState(
      checklist: event.checklist,
      checked: List.filled(event.checklist.items.length, false),
    ));
  }

  void _onItemToggled(
    ChecklistRunItemToggled event,
    Emitter<ChecklistRunState> emit,
  ) {
    final checked = [...state.checked];
    checked[event.index] = !checked[event.index];
    emit(state.copyWith(checked: checked));
  }
}
