import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/firestore/team_repository.dart';
import '../../../core/models/team.dart';

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
  const TeamCreateRequested({required this.name, required this.ownerUid});
  final String name;
  final String ownerUid;

  @override
  List<Object?> get props => [name, ownerUid];
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
  TeamListBloc({required TeamRepository teamRepository})
      : _teamRepository = teamRepository,
        super(const TeamListState()) {
    on<TeamListLoadRequested>(_onLoadRequested);
    on<TeamListUpdated>(_onUpdated);
    on<TeamCreateRequested>(_onCreateRequested);
    on<TeamDeleteRequested>(_onDeleteRequested);
  }

  final TeamRepository _teamRepository;
  StreamSubscription<List<Team>>? _subscription;

  Future<void> _onLoadRequested(
    TeamListLoadRequested event,
    Emitter<TeamListState> emit,
  ) async {
    emit(state.copyWith(status: TeamListStatus.loading));
    await _subscription?.cancel();
    _subscription = _teamRepository.teams(event.userUid).listen(
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
    final team = Team(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: event.name,
      ownerUid: event.ownerUid,
      createdAt: DateTime.now(),
      memberUids: [event.ownerUid],
    );
    await _teamRepository.saveTeam(team);
  }

  Future<void> _onDeleteRequested(
    TeamDeleteRequested event,
    Emitter<TeamListState> emit,
  ) async {
    await _teamRepository.deleteTeam(event.teamId);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}