import 'package:pocketbase/pocketbase.dart';

import '../core/models/team_event.dart';
import '../core/pocketbase/pb_client.dart';
import '../core/pocketbase/pb_realtime.dart';

abstract class EventService {
  Stream<List<TeamEvent>> getEvents(String teamId);
  Future<TeamEvent?> getEvent(String id);
  Future<TeamEvent> createEvent(TeamEvent event);
  Future<void> updateEvent(TeamEvent event);
  Future<void> deleteEvent(String id);
  Future<List<TeamEvent>> getUpcomingEvents(String userId);
}

class PbEventService implements EventService {
  PbEventService({PbClient? client, PbRealtime? realtime})
      : _client = client ?? PbClient.instance,
        _realtime = realtime ?? PbRealtime();

  final PbClient _client;
  final PbRealtime _realtime;

  PocketBase get _pb => _client.pb;

  @override
  Stream<List<TeamEvent>> getEvents(String teamId) {
    return _realtime
        .subscribeToList(
          'events',
          filter: 'teamId = "$teamId"',
          sort: 'dateTime',
        )
        .map((records) => records.map(_eventFromRecord).toList());
  }

  @override
  Future<TeamEvent?> getEvent(String id) async {
    try {
      final record = await _pb.collection('events').getOne(id);
      return _eventFromRecord(record);
    } on ClientException {
      return null;
    }
  }

  @override
  Future<TeamEvent> createEvent(TeamEvent event) async {
    final record = await _pb.collection('events').create(body: {
      'teamId': event.teamId,
      'title': event.title,
      'type': event.type.name,
      'dateTime': event.dateTime.toUtc().toIso8601String(),
      'location': event.location,
      'notes': event.notes,
      'recurring': false,
    });
    return _eventFromRecord(record);
  }

  @override
  Future<void> updateEvent(TeamEvent event) async {
    await _pb.collection('events').update(event.id, body: {
      'title': event.title,
      'type': event.type.name,
      'dateTime': event.dateTime.toUtc().toIso8601String(),
      'location': event.location,
      'notes': event.notes,
    });
  }

  @override
  Future<void> deleteEvent(String id) async {
    await _pb.collection('events').delete(id);
  }

  @override
  Future<List<TeamEvent>> getUpcomingEvents(String userId) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final records = await _pb.collection('events').getFullList(
          filter: 'dateTime >= "$now"',
          sort: 'dateTime',
          expand: 'teamId',
        );
    return records.map(_eventFromRecord).toList();
  }

  TeamEvent _eventFromRecord(RecordModel record) {
    return TeamEvent(
      id: record.id,
      teamId: record.getStringValue('teamId'),
      title: record.getStringValue('title'),
      type: EventType.values.byName(record.getStringValue('type')),
      dateTime:
          DateTime.tryParse(record.getStringValue('dateTime')) ?? DateTime.now(),
      location: record.getStringValue('location'),
      notes: record.getStringValue('notes'),
    );
  }
}
