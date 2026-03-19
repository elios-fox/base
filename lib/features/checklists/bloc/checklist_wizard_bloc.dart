import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/checklist.dart';

part 'checklist_wizard_event.dart';
part 'checklist_wizard_state.dart';

class ChecklistWizardBloc
    extends Bloc<ChecklistWizardEvent, ChecklistWizardState> {
  ChecklistWizardBloc() : super(const ChecklistWizardState()) {
    on<ChecklistWizardStarted>(_onStarted);
    on<ChecklistWizardNext>(_onNext);
    on<ChecklistWizardPrevious>(_onPrevious);
    on<ChecklistWizardItemCompleted>(_onItemCompleted);
  }

  void _onStarted(
    ChecklistWizardStarted event,
    Emitter<ChecklistWizardState> emit,
  ) {
    emit(ChecklistWizardState(
      checklist: event.checklist,
      currentIndex: 0,
      completed: List.filled(event.checklist.items.length, false),
    ));
  }

  void _onNext(
    ChecklistWizardNext event,
    Emitter<ChecklistWizardState> emit,
  ) {
    if (state.checklist == null) return;
    final maxIndex = state.checklist!.items.length - 1;
    if (state.currentIndex < maxIndex) {
      emit(state.copyWith(currentIndex: state.currentIndex + 1));
    }
  }

  void _onPrevious(
    ChecklistWizardPrevious event,
    Emitter<ChecklistWizardState> emit,
  ) {
    if (state.currentIndex > 0) {
      emit(state.copyWith(currentIndex: state.currentIndex - 1));
    }
  }

  void _onItemCompleted(
    ChecklistWizardItemCompleted event,
    Emitter<ChecklistWizardState> emit,
  ) {
    final completed = [...state.completed];
    completed[state.currentIndex] = !completed[state.currentIndex];
    emit(state.copyWith(completed: completed));
  }
}
