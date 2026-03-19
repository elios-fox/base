part of 'checklist_create_bloc.dart';

sealed class ChecklistCreateEvent extends Equatable {
  const ChecklistCreateEvent();

  @override
  List<Object?> get props => [];
}

final class ChecklistCreateStarted extends ChecklistCreateEvent {
  const ChecklistCreateStarted({this.existingId});

  final String? existingId;

  @override
  List<Object?> get props => [existingId];
}

final class ChecklistCreateTitleChanged extends ChecklistCreateEvent {
  const ChecklistCreateTitleChanged(this.title);

  final String title;

  @override
  List<Object?> get props => [title];
}

final class ChecklistCreateItemAdded extends ChecklistCreateEvent {
  const ChecklistCreateItemAdded(this.item);

  final ChecklistItem item;

  @override
  List<Object?> get props => [item];
}

final class ChecklistCreateItemRemoved extends ChecklistCreateEvent {
  const ChecklistCreateItemRemoved(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

final class ChecklistCreateItemUpdated extends ChecklistCreateEvent {
  const ChecklistCreateItemUpdated(this.index, this.item);

  final int index;
  final ChecklistItem item;

  @override
  List<Object?> get props => [index, item];
}

final class ChecklistCreateItemPhotoSelected extends ChecklistCreateEvent {
  const ChecklistCreateItemPhotoSelected(this.index, this.photo);

  final int index;
  final File photo;

  @override
  List<Object?> get props => [index, photo];
}

final class ChecklistCreateItemReordered extends ChecklistCreateEvent {
  const ChecklistCreateItemReordered(this.oldIndex, this.newIndex);

  final int oldIndex;
  final int newIndex;

  @override
  List<Object?> get props => [oldIndex, newIndex];
}

final class ChecklistCreateSubmitted extends ChecklistCreateEvent {
  const ChecklistCreateSubmitted();
}
