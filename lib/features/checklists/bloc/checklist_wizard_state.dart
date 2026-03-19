part of 'checklist_wizard_bloc.dart';

final class ChecklistWizardState extends Equatable {
  const ChecklistWizardState({
    this.checklist,
    this.currentIndex = 0,
    this.completed = const [],
  });

  final Checklist? checklist;
  final int currentIndex;
  final List<bool> completed;

  ChecklistWizardState copyWith({
    Checklist? checklist,
    int? currentIndex,
    List<bool>? completed,
  }) {
    return ChecklistWizardState(
      checklist: checklist ?? this.checklist,
      currentIndex: currentIndex ?? this.currentIndex,
      completed: completed ?? this.completed,
    );
  }

  @override
  List<Object?> get props => [checklist, currentIndex, completed];
}
