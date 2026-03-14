part of 'bardienst_bloc.dart';

enum BardienstStatus { initial, loading, loaded, failure }

final class BardienstState extends Equatable {
  const BardienstState({
    this.status = BardienstStatus.initial,
    this.checklists = const [],
  });

  final BardienstStatus status;
  final List<Checklist> checklists;

  BardienstState copyWith({
    BardienstStatus? status,
    List<Checklist>? checklists,
  }) {
    return BardienstState(
      status: status ?? this.status,
      checklists: checklists ?? this.checklists,
    );
  }

  @override
  List<Object?> get props => [status, checklists];
}
