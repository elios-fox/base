part of 'bardienst_bloc.dart';

sealed class BardienstEvent extends Equatable {
  const BardienstEvent();

  @override
  List<Object?> get props => [];
}

final class BardienstLoadRequested extends BardienstEvent {
  const BardienstLoadRequested({required this.ownerUid});

  final String ownerUid;

  @override
  List<Object?> get props => [ownerUid];
}

final class BardienstChecklistDeleted extends BardienstEvent {
  const BardienstChecklistDeleted({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}
