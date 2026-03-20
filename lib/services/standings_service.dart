import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/models/match_result.dart';

class StandingsService {
  StandingsService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  /// Stream van match results voor een team (via join met events).
  Stream<List<MatchResult>> getMatchResults(String teamId) {
    return _supabase
        .from('match_results')
        .stream(primaryKey: ['id'])
        .map((rows) => rows
            .map((row) => MatchResult.fromJson(row))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  /// Haal match results op voor een team (eenmalig, met join).
  Future<List<MatchResult>> fetchMatchResults(String teamId) async {
    final response = await _supabase
        .from('match_results')
        .select('*, events!inner(team_id)')
        .eq('events.team_id', teamId)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((row) => MatchResult.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  /// Uitslag invoeren voor een wedstrijd.
  Future<MatchResult> submitResult({
    required String eventId,
    required int homeScore,
    required int awayScore,
    required String opponentName,
  }) async {
    final response = await _supabase
        .from('match_results')
        .insert({
          'event_id': eventId,
          'home_score': homeScore,
          'away_score': awayScore,
          'opponent_name': opponentName,
        })
        .select()
        .single();

    return MatchResult.fromJson(response);
  }

  /// Uitslag bijwerken.
  Future<MatchResult> updateResult(MatchResult result) async {
    final response = await _supabase
        .from('match_results')
        .update(result.toJson())
        .eq('id', result.id)
        .select()
        .single();

    return MatchResult.fromJson(response);
  }

  /// Uitslag verwijderen.
  Future<void> deleteResult(String id) async {
    await _supabase.from('match_results').delete().eq('id', id);
  }
}
