import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/match_result.dart';
import '../../../core/models/standing_entry.dart';
import '../../../services/standings_service.dart';

part 'standings_event.dart';
part 'standings_state.dart';

class StandingsBloc extends Bloc<StandingsEvent, StandingsState> {
  StandingsBloc({required StandingsService standingsService})
      : _standingsService = standingsService,
        super(const StandingsState()) {
    on<StandingsLoadRequested>(_onLoadRequested);
    on<ResultSubmitted>(_onResultSubmitted);
    on<ResultDeleted>(_onResultDeleted);
  }

  final StandingsService _standingsService;

  Future<void> _onLoadRequested(
    StandingsLoadRequested event,
    Emitter<StandingsState> emit,
  ) async {
    emit(state.copyWith(status: StandingsStatus.loading));
    try {
      final results = await _standingsService.fetchMatchResults(event.teamId);
      final standings = _calculateStandings(results);
      emit(state.copyWith(
        status: StandingsStatus.loaded,
        matchResults: results,
        standings: standings,
        teamId: event.teamId,
      ));
    } catch (e) {
      emit(state.copyWith(status: StandingsStatus.failure));
    }
  }

  Future<void> _onResultSubmitted(
    ResultSubmitted event,
    Emitter<StandingsState> emit,
  ) async {
    try {
      await _standingsService.submitResult(
        eventId: event.eventId,
        homeScore: event.homeScore,
        awayScore: event.awayScore,
        opponentName: event.opponentName,
      );
      // Herlaad standen na invoer
      if (state.teamId != null) {
        add(StandingsLoadRequested(teamId: state.teamId!));
      }
    } catch (e) {
      emit(state.copyWith(status: StandingsStatus.failure));
    }
  }

  Future<void> _onResultDeleted(
    ResultDeleted event,
    Emitter<StandingsState> emit,
  ) async {
    try {
      await _standingsService.deleteResult(event.id);
      // Herlaad standen na verwijdering
      if (state.teamId != null) {
        add(StandingsLoadRequested(teamId: state.teamId!));
      }
    } catch (e) {
      emit(state.copyWith(status: StandingsStatus.failure));
    }
  }

  /// Bereken de stand uit de match results.
  /// Eigen team = thuis, tegenstander = uit.
  /// W=3pts, G=1pt, V=0pts.
  List<StandingEntry> _calculateStandings(List<MatchResult> results) {
    if (results.isEmpty) return [];

    // Verzamel alle teams
    final teamStats = <String, StandingEntry>{};

    // Naam eigen team (thuis)
    const ownTeamName = 'Eigen team';

    for (final result in results) {
      // Eigen team bijwerken
      final ownEntry = teamStats[ownTeamName] ??
          const StandingEntry(teamName: ownTeamName);
      final opponentEntry = teamStats[result.opponentName] ??
          StandingEntry(teamName: result.opponentName);

      if (result.homeScore > result.awayScore) {
        // Winst
        teamStats[ownTeamName] = ownEntry.copyWith(
          played: ownEntry.played + 1,
          won: ownEntry.won + 1,
        );
        teamStats[result.opponentName] = opponentEntry.copyWith(
          played: opponentEntry.played + 1,
          lost: opponentEntry.lost + 1,
        );
      } else if (result.homeScore == result.awayScore) {
        // Gelijkspel
        teamStats[ownTeamName] = ownEntry.copyWith(
          played: ownEntry.played + 1,
          drawn: ownEntry.drawn + 1,
        );
        teamStats[result.opponentName] = opponentEntry.copyWith(
          played: opponentEntry.played + 1,
          drawn: opponentEntry.drawn + 1,
        );
      } else {
        // Verlies
        teamStats[ownTeamName] = ownEntry.copyWith(
          played: ownEntry.played + 1,
          lost: ownEntry.lost + 1,
        );
        teamStats[result.opponentName] = opponentEntry.copyWith(
          played: opponentEntry.played + 1,
          won: opponentEntry.won + 1,
        );
      }
    }

    // Sorteer op punten (desc), dan op gewonnen (desc)
    final standings = teamStats.values.toList()
      ..sort((a, b) {
        final pointsDiff = b.points.compareTo(a.points);
        if (pointsDiff != 0) return pointsDiff;
        return b.won.compareTo(a.won);
      });

    return standings;
  }
}
