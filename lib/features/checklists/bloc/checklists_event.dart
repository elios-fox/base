part of 'checklists_bloc.dart';

sealed class ChecklistsEvent extends Equatable {
  const ChecklistsEvent();

  @override
  List<Object?> get props => [];
}

final class ChecklistsLoadRequested extends ChecklistsEvent {
  const ChecklistsLoadRequested({required this.ownerUid});

  final String ownerUid;

  @override
  List<Object?> get props => [ownerUid];
}

final class ChecklistsChecklistDeleted extends ChecklistsEvent {
  const ChecklistsChecklistDeleted({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}
