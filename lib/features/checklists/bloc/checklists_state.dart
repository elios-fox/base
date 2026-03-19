part of 'checklists_bloc.dart';

enum ChecklistsStatus { initial, loading, loaded, failure }

final class ChecklistsState extends Equatable {
  const ChecklistsState({
    this.status = ChecklistsStatus.initial,
    this.checklists = const [],
  });

  final ChecklistsStatus status;
  final List<Checklist> checklists;

  ChecklistsState copyWith({
    ChecklistsStatus? status,
    List<Checklist>? checklists,
  }) {
    return ChecklistsState(
      status: status ?? this.status,
      checklists: checklists ?? this.checklists,
    );
  }

  @override
  List<Object?> get props => [status, checklists];
}
