import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/team.dart';
import '../../../services/team_service.dart';

// Events
sealed class TeamDetailEvent extends Equatable {
  const TeamDetailEvent();
  @override
  List<Object?> get props => [];
}

final class TeamDetailLoadRequested extends TeamDetailEvent {
  const TeamDetailLoadRequested(this.teamId);
  final String teamId;
  @override
  List<Object?> get props => [teamId];
}

final class TeamDetailMemberRemoved extends TeamDetailEvent {
  const TeamDetailMemberRemoved({required this.teamId, required this.memberUid});
  final String teamId;
  final String memberUid;
  @override
  List<Object?> get props => [teamId, memberUid];
}

final class TeamDetailInviteCodeCopied extends TeamDetailEvent {
  const TeamDetailInviteCodeCopied(this.inviteCode);
  final String inviteCode;
  @override
  List<Object?> get props => [inviteCode];
}

// State
enum TeamDetailStatus { initial, loading, loaded, failure }

final class TeamDetailState extends Equatable {
  const TeamDetailState({
    this.status = TeamDetailStatus.initial,
    this.team,
    this.codeCopied = false,
  });

  final TeamDetailStatus status;
  final Team? team;
  final bool codeCopied;

  TeamDetailState copyWith({
    TeamDetailStatus? status,
    Team? team,
    bool? codeCopied,
  }) {
    return TeamDetailState(
      status: status ?? this.status,
      team: team ?? this.team,
      codeCopied: codeCopied ?? this.codeCopied,
    );
  }

  @override
  List<Object?> get props => [status, team, codeCopied];
}

// Bloc
class TeamDetailBloc extends Bloc<TeamDetailEvent, TeamDetailState> {
  TeamDetailBloc({required TeamService teamService})
      : _teamService = teamService,
        super(const TeamDetailState()) {
    on<TeamDetailLoadRequested>(_onLoadRequested);
    on<TeamDetailMemberRemoved>(_onMemberRemoved);
    on<TeamDetailInviteCodeCopied>(_onInviteCodeCopied);
  }

  final TeamService _teamService;

  Future<void> _onLoadRequested(
    TeamDetailLoadRequested event,
    Emitter<TeamDetailState> emit,
  ) async {
    emit(state.copyWith(status: TeamDetailStatus.loading));
    try {
      final team = await _teamService.getTeam(event.teamId);
      emit(state.copyWith(status: TeamDetailStatus.loaded, team: team));
    } catch (_) {
      emit(state.copyWith(status: TeamDetailStatus.failure));
    }
  }

  Future<void> _onMemberRemoved(
    TeamDetailMemberRemoved event,
    Emitter<TeamDetailState> emit,
  ) async {
    if (state.team == null) return;
    final updatedMembers =
        state.team!.memberUids.where((uid) => uid != event.memberUid).toList();
    final updatedTeam = state.team!.copyWith(memberUids: updatedMembers);
    await _teamService.updateTeam(updatedTeam);
    emit(state.copyWith(team: updatedTeam));
  }

  Future<void> _onInviteCodeCopied(
    TeamDetailInviteCodeCopied event,
    Emitter<TeamDetailState> emit,
  ) async {
    await Clipboard.setData(ClipboardData(text: event.inviteCode));
    emit(state.copyWith(codeCopied: true));
    await Future.delayed(const Duration(seconds: 2));
    emit(state.copyWith(codeCopied: false));
  }
}
