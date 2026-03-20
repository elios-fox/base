part of 'standings_bloc.dart';

enum StandingsStatus { initial, loading, loaded, failure }

final class StandingsState extends Equatable {
  const StandingsState({
    this.status = StandingsStatus.initial,
    this.matchResults = const [],
    this.standings = const [],
    this.teamId,
  });

  final StandingsStatus status;
  final List<MatchResult> matchResults;
  final List<StandingEntry> standings;
  final String? teamId;

  StandingsState copyWith({
    StandingsStatus? status,
    List<MatchResult>? matchResults,
    List<StandingEntry>? standings,
    String? teamId,
  }) {
    return StandingsState(
      status: status ?? this.status,
      matchResults: matchResults ?? this.matchResults,
      standings: standings ?? this.standings,
      teamId: teamId ?? this.teamId,
    );
  }

  @override
  List<Object?> get props => [status, matchResults, standings, teamId];
}
