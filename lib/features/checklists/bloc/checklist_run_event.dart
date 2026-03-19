part of 'checklist_run_bloc.dart';

sealed class ChecklistRunEvent extends Equatable {
  const ChecklistRunEvent();

  @override
  List<Object?> get props => [];
}

final class ChecklistRunStarted extends ChecklistRunEvent {
  const ChecklistRunStarted(this.checklist);

  final Checklist checklist;

  @override
  List<Object?> get props => [checklist];
}

final class ChecklistRunItemToggled extends ChecklistRunEvent {
  const ChecklistRunItemToggled(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}
