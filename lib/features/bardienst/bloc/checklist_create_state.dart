part of 'checklist_create_bloc.dart';

enum ChecklistCreateStatus { initial, loading, saving, success, failure }

final class ChecklistCreateState extends Equatable {
  const ChecklistCreateState({
    this.status = ChecklistCreateStatus.initial,
    this.title = '',
    this.items = const [],
    this.errorMessage = '',
  });

  final ChecklistCreateStatus status;
  final String title;
  final List<ChecklistItem> items;
  final String errorMessage;

  ChecklistCreateState copyWith({
    ChecklistCreateStatus? status,
    String? title,
    List<ChecklistItem>? items,
    String? errorMessage,
  }) {
    return ChecklistCreateState(
      status: status ?? this.status,
      title: title ?? this.title,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, title, items, errorMessage];
}
