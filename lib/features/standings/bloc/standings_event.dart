part of 'standings_bloc.dart';

sealed class StandingsEvent extends Equatable {
  const StandingsEvent();

  @override
  List<Object?> get props => [];
}

final class StandingsLoadRequested extends StandingsEvent {
  const StandingsLoadRequested({required this.teamId});

  final String teamId;

  @override
  List<Object?> get props => [teamId];
}

final class ResultSubmitted extends StandingsEvent {
  const ResultSubmitted({
    required this.eventId,
    required this.homeScore,
    required this.awayScore,
    required this.opponentName,
  });

  final String eventId;
  final int homeScore;
  final int awayScore;
  final String opponentName;

  @override
  List<Object?> get props => [eventId, homeScore, awayScore, opponentName];
}

final class ResultDeleted extends StandingsEvent {
  const ResultDeleted({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}
