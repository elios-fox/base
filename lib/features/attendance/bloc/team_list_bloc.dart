import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/team.dart';
import '../../../services/team_service.dart';

// Events
sealed class TeamListEvent extends Equatable {
  const TeamListEvent();

  @override
  List<Object?> get props => [];
}

final class TeamListLoadRequested extends TeamListEvent {
  const TeamListLoadRequested({required this.userUid});
  final String userUid;

  @override
  List<Object?> get props => [userUid];
}

final class TeamListUpdated extends TeamListEvent {
  const TeamListUpdated(this.teams);
  final List<Team> teams;

  @override
  List<Object?> get props => [teams];
}

final class TeamCreateRequested extends TeamListEvent {
  const TeamCreateRequested({
    required this.name,
    required this.ownerUid,
    this.sport = '',
    this.clubId,
  });
  final String name;
  final String ownerUid;
  final String sport;
  final String? clubId;

  @override
  List<Object?> get props => [name, ownerUid, sport, clubId];
}

final class TeamDeleteRequested extends TeamListEvent {
  const TeamDeleteRequested(this.teamId);
  final String teamId;

  @override
  List<Object?> get props => [teamId];
}

// State
enum TeamListStatus { initial, loading, loaded, failure }

final class TeamListState extends Equatable {
  const TeamListState({
    this.status = TeamListStatus.initial,
    this.teams = const [],
  });

  final TeamListStatus status;
  final List<Team> teams;

  TeamListState copyWith({
    TeamListStatus? status,
    List<Team>? teams,
  }) {
    return TeamListState(
      status: status ?? this.status,
      teams: teams ?? this.teams,
    );
  }

  @override
  List<Object?> get props => [status, teams];
}

// Bloc
class TeamListBloc extends Bloc<TeamListEvent, TeamListState> {
  TeamListBloc({required TeamService teamService})
      : _teamService = teamService,
        super(const TeamListState()) {
    on<TeamListLoadRequested>(_onLoadRequested);
    on<TeamListUpdated>(_onUpdated);
    on<TeamCreateRequested>(_onCreateRequested);
    on<TeamDeleteRequested>(_onDeleteRequested);
  }

  final TeamService _teamService;
  StreamSubscription<List<Team>>? _subscription;

  Future<void> _onLoadRequested(
    TeamListLoadRequested event,
    Emitter<TeamListState> emit,
  ) async {
    emit(state.copyWith(status: TeamListStatus.loading));
    await _subscription?.cancel();
    _subscription = _teamService.getTeams(event.userUid).listen(
          (teams) => add(TeamListUpdated(teams)),
        );
  }

  void _onUpdated(
    TeamListUpdated event,
    Emitter<TeamListState> emit,
  ) {
    emit(state.copyWith(
      status: TeamListStatus.loaded,
      teams: event.teams,
    ));
  }

  Future<void> _onCreateRequested(
    TeamCreateRequested event,
    Emitter<TeamListState> emit,
  ) async {
    await _teamService.createTeam(
      event.name,
      event.ownerUid,
      event.sport,
      clubId: event.clubId,
    );
  }

  Future<void> _onDeleteRequested(
    TeamDeleteRequested event,
    Emitter<TeamListState> emit,
  ) async {
    await _teamService.deleteTeam(event.teamId);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}