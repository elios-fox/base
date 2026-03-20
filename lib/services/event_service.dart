import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/models/recurring_pattern.dart';
import '../core/models/team_event.dart';
import '../core/supabase/supabase_client.dart';
import '../core/supabase/supabase_realtime.dart';

abstract class EventService {
  Stream<List<TeamEvent>> getEvents(String teamId);
  Future<TeamEvent?> getEvent(String id);
  Future<TeamEvent> createEvent(TeamEvent event);
  Future<List<TeamEvent>> createRecurringEvents(
      TeamEvent template, RecurringPattern pattern);
  Future<void> updateEvent(TeamEvent event);
  Future<void> deleteEvent(String id);
  Future<List<TeamEvent>> getUpcomingEvents(String userId);
}

class SupaEventService implements EventService {
  SupaEventService({SupabaseClientWrapper? client, SupabaseRealtime? realtime})
      : _client = client ?? SupabaseClientWrapper.instance,
        _realtime = realtime ?? SupabaseRealtime();

  final SupabaseClientWrapper _client;
  final SupabaseRealtime _realtime;

  SupabaseClient get _supabase => _client.client;

  @override
  Stream<List<TeamEvent>> getEvents(String teamId) {
    return _realtime
        .subscribeToList(
          'events',
          column: 'team_id',
          value: teamId,
          orderBy: 'date_time',
          ascending: true,
        )
        .map((rows) => rows.map(_eventFromMap).toList());
  }

  @override
  Future<TeamEvent?> getEvent(String id) async {
    try {
      final data =
          await _supabase.from('events').select().eq('id', id).maybeSingle();
      if (data == null) return null;
      return _eventFromMap(data);
    } on PostgrestException {
      return null;
    }
  }

  @override
  Future<TeamEvent> createEvent(TeamEvent event) async {
    final data = await _supabase.from('events').insert({
      'team_id': event.teamId,
      'title': event.title,
      'type': event.type.name,
      'date_time': event.dateTime.toUtc().toIso8601String(),
      'location': event.location,
      'notes': event.notes,
      'recurring': event.recurring,
      if (event.recurringPattern != null)
        'recurring_pattern': event.recurringPattern!.toJson(),
    }).select().single();
    return _eventFromMap(data);
  }

  @override
  Future<List<TeamEvent>> createRecurringEvents(
    TeamEvent template,
    RecurringPattern pattern,
  ) async {
    final events = <TeamEvent>[];
    final interval = pattern.frequency == RecurringFrequency.weekly
        ? const Duration(days: 7)
        : const Duration(days: 14);

    var current = template.dateTime;
    // Adjust to the correct day of week
    while (current.weekday != pattern.dayOfWeek) {
      current = current.add(const Duration(days: 1));
    }

    while (!current.isAfter(pattern.endDate)) {
      final event = await createEvent(template.copyWith(
        dateTime: current,
        recurring: true,
        recurringPattern: pattern,
      ));
      events.add(event);
      current = current.add(interval);
    }

    return events;
  }

  @override
  Future<void> updateEvent(TeamEvent event) async {
    await _supabase.from('events').update({
      'title': event.title,
      'type': event.type.name,
      'date_time': event.dateTime.toUtc().toIso8601String(),
      'location': event.location,
      'notes': event.notes,
    }).eq('id', event.id);
  }

  @override
  Future<void> deleteEvent(String id) async {
    await _supabase.from('events').delete().eq('id', id);
  }

  @override
  Future<List<TeamEvent>> getUpcomingEvents(String userId) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final data = await _supabase
        .from('events')
        .select()
        .gte('date_time', now)
        .order('date_time', ascending: true);
    return data.map(_eventFromMap).toList();
  }

  TeamEvent _eventFromMap(Map<String, dynamic> map) {
    return TeamEvent(
      id: map['id'] as String,
      teamId: map['team_id'] as String,
      title: map['title'] as String,
      type: EventType.values.byName(map['type'] as String),
      dateTime:
          DateTime.tryParse(map['date_time'] as String? ?? '') ?? DateTime.now(),
      location: map['location'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      recurring: map['recurring'] as bool? ?? false,
      recurringPattern: map['recurring_pattern'] != null
          ? RecurringPattern.fromJson(
              Map<String, dynamic>.from(map['recurring_pattern'] as Map))
          : null,
    );
  }
}
