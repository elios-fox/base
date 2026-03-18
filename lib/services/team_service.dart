import 'package:pocketbase/pocketbase.dart';

import '../core/models/team.dart';
import '../core/pocketbase/pb_client.dart';
import '../core/pocketbase/pb_realtime.dart';

abstract class TeamService {
  Stream<List<Team>> getTeams(String userId);
  Future<Team?> getTeam(String id);
  Future<Team> createTeam(String name, String ownerUid, String sport);
  Future<void> updateTeam(Team team);
  Future<void> deleteTeam(String id);
  Future<Team> joinTeam(String inviteCode);
  Future<void> leaveTeam(String teamId, String userId);
}

class PbTeamService implements TeamService {
  PbTeamService({PbClient? client, PbRealtime? realtime})
      : _client = client ?? PbClient.instance,
        _realtime = realtime ?? PbRealtime();

  final PbClient _client;
  final PbRealtime _realtime;

  PocketBase get _pb => _client.pb;

  @override
  Stream<List<Team>> getTeams(String userId) {
    return _realtime
        .subscribeToList(
          'teams',
          filter: 'memberUids.id ?= "$userId"',
          sort: 'name',
        )
        .map((records) => records.map(_teamFromRecord).toList());
  }

  @override
  Future<Team?> getTeam(String id) async {
    try {
      final record = await _pb.collection('teams').getOne(id);
      return _teamFromRecord(record);
    } on ClientException {
      return null;
    }
  }

  @override
  Future<Team> createTeam(String name, String ownerUid, String sport) async {
    final record = await _pb.collection('teams').create(body: {
      'name': name,
      'ownerUid': ownerUid,
      'sport': sport,
      'seasonYear': DateTime.now().year,
      'memberUids': [ownerUid],
    });
    return _teamFromRecord(record);
  }

  @override
  Future<void> updateTeam(Team team) async {
    await _pb.collection('teams').update(team.id, body: team.toFirestore());
  }

  @override
  Future<void> deleteTeam(String id) async {
    await _pb.collection('teams').delete(id);
  }

  @override
  Future<Team> joinTeam(String inviteCode) async {
    final result = await _pb.send(
      '/api/clubhub/teams/join',
      method: 'POST',
      body: {'inviteCode': inviteCode},
    );
    final teamId = result['teamId'] as String;
    final team = await getTeam(teamId);
    return team!;
  }

  @override
  Future<void> leaveTeam(String teamId, String userId) async {
    final record = await _pb.collection('teams').getOne(teamId);
    final memberUids = List<String>.from(record.get<List>('memberUids'));
    memberUids.remove(userId);
    await _pb.collection('teams').update(teamId, body: {
      'memberUids': memberUids,
    });
  }

  Team _teamFromRecord(RecordModel record) {
    return Team(
      id: record.id,
      name: record.getStringValue('name'),
      ownerUid: record.getStringValue('ownerUid'),
      createdAt: DateTime.tryParse(record.get<String>('created')) ?? DateTime.now(),
      memberUids: List<String>.from(record.get<List>('memberUids')),
    );
  }
}
