part of 'checklist_run_bloc.dart';

final class ChecklistRunState extends Equatable {
  const ChecklistRunState({
    this.checklist,
    this.checked = const [],
  });

  final Checklist? checklist;
  final List<bool> checked;

  ChecklistRunState copyWith({
    Checklist? checklist,
    List<bool>? checked,
  }) {
    return ChecklistRunState(
      checklist: checklist ?? this.checklist,
      checked: checked ?? this.checked,
    );
  }

  @override
  List<Object?> get props => [checklist, checked];
}
