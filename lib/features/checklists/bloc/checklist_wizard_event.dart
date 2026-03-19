part of 'checklist_wizard_bloc.dart';

sealed class ChecklistWizardEvent extends Equatable {
  const ChecklistWizardEvent();

  @override
  List<Object?> get props => [];
}

final class ChecklistWizardStarted extends ChecklistWizardEvent {
  const ChecklistWizardStarted(this.checklist);

  final Checklist checklist;

  @override
  List<Object?> get props => [checklist];
}

final class ChecklistWizardNext extends ChecklistWizardEvent {
  const ChecklistWizardNext();
}

final class ChecklistWizardPrevious extends ChecklistWizardEvent {
  const ChecklistWizardPrevious();
}

final class ChecklistWizardItemCompleted extends ChecklistWizardEvent {
  const ChecklistWizardItemCompleted();
}
