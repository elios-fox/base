import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/attendance.dart';
import '../models/team.dart';
import '../models/team_event.dart';

abstract class TeamRepository {
  Stream<List<Team>> teams(String userUid);
  Future<Team?> getTeam(String id);
  Future<void> saveTeam(Team team);
  Future<void> deleteTeam(String teamId);
  Future<Team> joinTeamByCode(String code, String userUid);
  Stream<List<TeamEvent>> events(String teamId);
  Future<void> saveEvent(TeamEvent event);
  Future<void> deleteEvent(String eventId);
  Stream<List<Attendance>> attendances(String eventId);
  Future<void> saveAttendance(Attendance attendance);
}

class FirebaseTeamRepository implements TeamRepository {
  FirebaseTeamRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _teams =>
      _firestore.collection('teams');

  CollectionReference<Map<String, dynamic>> get _events =>
      _firestore.collection('events');

  CollectionReference<Map<String, dynamic>> get _attendances =>
      _firestore.collection('attendances');

  @override
  Stream<List<Team>> teams(String userUid) {
    return _teams
        .where('memberUids', arrayContains: userUid)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map(Team.fromFirestore).toList();
      list.sort((a, b) => a.name.compareTo(b.name));
      return list;
    });
  }

  @override
  Future<Team?> getTeam(String id) async {
    final doc = await _teams.doc(id).get();
    if (!doc.exists) return null;
    return Team.fromFirestore(doc);
  }

  @override
  Future<void> saveTeam(Team team) async {
    await _teams.doc(team.id).set(team.toFirestore());
  }

  @override
  Future<void> deleteTeam(String teamId) async {
    await _teams.doc(teamId).delete();
  }

  @override
  Future<Team> joinTeamByCode(String code, String userUid) async {
    final doc = await _teams.doc(code).get();
    if (!doc.exists) {
      throw Exception('Team niet gevonden met deze code.');
    }
    final team = Team.fromFirestore(doc);
    if (team.memberUids.contains(userUid)) {
      return team;
    }
    final updatedTeam = team.copyWith(
      memberUids: [...team.memberUids, userUid],
    );
    await _teams.doc(team.id).set(updatedTeam.toFirestore());
    return updatedTeam;
  }

  @override
  Stream<List<TeamEvent>> events(String teamId) {
    return _events
        .where('teamId', isEqualTo: teamId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map(TeamEvent.fromFirestore).toList();
      list.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return list;
    });
  }

  @override
  Future<void> saveEvent(TeamEvent event) async {
    await _events.doc(event.id).set(event.toFirestore());
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    await _events.doc(eventId).delete();
  }

  @override
  Stream<List<Attendance>> attendances(String eventId) {
    return _attendances
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map(Attendance.fromFirestore).toList();
      list.sort((a, b) => a.userName.compareTo(b.userName));
      return list;
    });
  }

  @override
  Future<void> saveAttendance(Attendance attendance) async {
    await _attendances.doc(attendance.id).set(attendance.toFirestore());
  }
}
