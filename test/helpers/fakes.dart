import 'package:base/core/models/attendance.dart';
import 'package:base/core/models/team.dart';
import 'package:base/core/models/team_event.dart';

Team fakeTeam({
  String id = 'team-1',
  String name = 'Heren 1',
  String ownerUid = 'user-1',
  List<String> memberUids = const ['user-1', 'user-2'],
}) {
  return Team(
    id: id,
    name: name,
    ownerUid: ownerUid,
    createdAt: DateTime(2026, 1, 1),
    memberUids: memberUids,
  );
}

TeamEvent fakeEvent({
  String id = 'event-1',
  String teamId = 'team-1',
  String title = 'Training',
  EventType type = EventType.training,
  DateTime? dateTime,
  String location = 'Sportpark Noord',
}) {
  return TeamEvent(
    id: id,
    teamId: teamId,
    title: title,
    type: type,
    dateTime: dateTime ?? DateTime(2026, 3, 20, 19, 0),
    location: location,
  );
}

Attendance fakeAttendance({
  String id = 'att-1',
  String eventId = 'event-1',
  String userUid = 'user-1',
  String userName = 'Jan de Vries',
  AttendanceStatus status = AttendanceStatus.aanwezig,
  String reason = '',
}) {
  return Attendance(
    id: id,
    eventId: eventId,
    userUid: userUid,
    userName: userName,
    status: status,
    reason: reason,
  );
}
