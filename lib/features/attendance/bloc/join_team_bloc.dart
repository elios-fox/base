import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/firestore/team_repository.dart';

// Events
sealed class JoinTeamEvent extends Equatable {
  const JoinTeamEvent();
  @override
  List<Object?> get props => [];
}

final class JoinTeamCodeChanged extends JoinTeamEvent {
  const JoinTeamCodeChanged(this.code);
  final String code;
  @override
  List<Object?> get props => [code];
}

final class JoinTeamSubmitted extends JoinTeamEvent {
  const JoinTeamSubmitted({required this.userUid});
  final String userUid;
  @override
  List<Object?> get props => [userUid];
}

// State
enum JoinTeamStatus { initial, submitting, success, failure }

final class JoinTeamState extends Equatable {
  const JoinTeamState({
    this.status = JoinTeamStatus.initial,
    this.code = '',
    this.teamName = '',
    this.teamId = '',
    this.errorMessage,
  });

  final JoinTeamStatus status;
  final String code;
  final String teamName;
  final String teamId;
  final String? errorMessage;

  JoinTeamState copyWith({
    JoinTeamStatus? status,
    String? code,
    String? teamName,
    String? teamId,
    String? errorMessage,
  }) {
    return JoinTeamState(
      status: status ?? this.status,
      code: code ?? this.code,
      teamName: teamName ?? this.teamName,
      teamId: teamId ?? this.teamId,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, code, teamName, teamId, errorMessage];
}

// Bloc
class JoinTeamBloc extends Bloc<JoinTeamEvent, JoinTeamState> {
  JoinTeamBloc({required TeamRepository teamRepository})
      : _teamRepository = teamRepository,
        super(const JoinTeamState()) {
    on<JoinTeamCodeChanged>(_onCodeChanged);
    on<JoinTeamSubmitted>(_onSubmitted);
  }

  final TeamRepository _teamRepository;

  void _onCodeChanged(
    JoinTeamCodeChanged event,
    Emitter<JoinTeamState> emit,
  ) {
    emit(state.copyWith(
      code: event.code,
      status: JoinTeamStatus.initial,
    ));
  }

  Future<void> _onSubmitted(
    JoinTeamSubmitted event,
    Emitter<JoinTeamState> emit,
  ) async {
    if (state.code.trim().isEmpty) {
      emit(state.copyWith(
        status: JoinTeamStatus.failure,
        errorMessage: 'Voer een code in.',
      ));
      return;
    }

    emit(state.copyWith(status: JoinTeamStatus.submitting));

    try {
      final team = await _teamRepository.joinTeamByCode(
        state.code.trim(),
        event.userUid,
      );
      emit(state.copyWith(
        status: JoinTeamStatus.success,
        teamName: team.name,
        teamId: team.id,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: JoinTeamStatus.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}
