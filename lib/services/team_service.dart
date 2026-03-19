import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/models/team.dart';
import '../core/supabase/supabase_client.dart';

abstract class TeamService {
  Stream<List<Team>> getTeams(String userId);
  Future<Team?> getTeam(String id);
  Future<Team> createTeam(String name, String ownerUid, String sport);
  Future<void> updateTeam(Team team);
  Future<void> deleteTeam(String id);
  Future<Team> joinTeam(String inviteCode);
  Future<void> leaveTeam(String teamId, String userId);
}

class SupaTeamService implements TeamService {
  SupaTeamService({SupabaseClientWrapper? client})
      : _client = client ?? SupabaseClientWrapper.instance;

  final SupabaseClientWrapper _client;

  SupabaseClient get _supabase => _client.client;

  @override
  Stream<List<Team>> getTeams(String userId) {
    // SupabaseRealtime.subscribeToList uses .eq(), but member_uids is an array.
    // We subscribe to the whole table and re-fetch with .contains() on each change.
    final controller = StreamController<List<Team>>.broadcast();

    Future<void> fetch() async {
      try {
        final data = await _supabase
            .from('teams')
            .select()
            .contains('member_uids', [userId])
            .order('name', ascending: true);
        if (!controller.isClosed) {
          controller.add(data.map(_teamFromMap).toList());
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError(e);
        }
      }
    }

    // Initial fetch
    fetch();

    // Subscribe to changes on the teams table
    final channel = _supabase
        .channel('public:teams:member:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'teams',
          callback: (_) => fetch(),
        )
        .subscribe();

    controller.onCancel = () {
      _supabase.removeChannel(channel);
    };

    return controller.stream;
  }

  @override
  Future<Team?> getTeam(String id) async {
    try {
      final data =
          await _supabase.from('teams').select().eq('id', id).maybeSingle();
      if (data == null) return null;
      return _teamFromMap(data);
    } on PostgrestException {
      return null;
    }
  }

  @override
  Future<Team> createTeam(String name, String ownerUid, String sport) async {
    final data = await _supabase.from('teams').insert({
      'name': name,
      'owner_uid': ownerUid,
      'sport': sport,
      'season_year': DateTime.now().year,
      'member_uids': [ownerUid],
    }).select().single();
    return _teamFromMap(data);
  }

  @override
  Future<void> updateTeam(Team team) async {
    await _supabase.from('teams').update({
      'name': team.name,
      'owner_uid': team.ownerUid,
      'member_uids': team.memberUids,
    }).eq('id', team.id);
  }

  @override
  Future<void> deleteTeam(String id) async {
    await _supabase.from('teams').delete().eq('id', id);
  }

  @override
  Future<Team> joinTeam(String inviteCode) async {
    final result = await _supabase.rpc('join_team', params: {
      'invite_code': inviteCode,
      'user_uid': _client.userId,
    });
    final teamId = result['team_id'] as String;
    final team = await getTeam(teamId);
    return team!;
  }

  @override
  Future<void> leaveTeam(String teamId, String userId) async {
    final data =
        await _supabase.from('teams').select().eq('id', teamId).single();
    final memberUids = List<String>.from(data['member_uids'] as List);
    memberUids.remove(userId);
    await _supabase.from('teams').update({
      'member_uids': memberUids,
    }).eq('id', teamId);
  }

  Team _teamFromMap(Map<String, dynamic> map) {
    return Team(
      id: map['id'] as String,
      name: map['name'] as String,
      ownerUid: map['owner_uid'] as String,
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      memberUids: List<String>.from(map['member_uids'] as List? ?? []),
    );
  }
}
