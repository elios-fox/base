import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/models/attendance.dart';
import '../core/supabase/supabase_client.dart';
import '../core/supabase/supabase_realtime.dart';

abstract class AttendanceService {
  Stream<List<Attendance>> getAttendances(String eventId);
  Future<void> submitAttendance({
    required String eventId,
    required String userId,
    required String userName,
    required AttendanceStatus status,
    String reason,
  });
  Future<Attendance?> getMyAttendance(String eventId, String userId);
  Future<AttendanceStats> getStats(String eventId);
  Future<List<Attendance>> getUserHistory(String userId, String teamId);
}

class AttendanceStats {
  const AttendanceStats({
    required this.aanwezig,
    required this.afwezig,
    required this.onzeker,
    required this.total,
  });

  final int aanwezig;
  final int afwezig;
  final int onzeker;
  final int total;
}

class SupaAttendanceService implements AttendanceService {
  SupaAttendanceService({
    SupabaseClientWrapper? client,
    SupabaseRealtime? realtime,
  })  : _client = client ?? SupabaseClientWrapper.instance,
        _realtime = realtime ?? SupabaseRealtime();

  final SupabaseClientWrapper _client;
  final SupabaseRealtime _realtime;

  SupabaseClient get _supabase => _client.client;

  @override
  Stream<List<Attendance>> getAttendances(String eventId) {
    return _realtime
        .subscribeToList(
          'attendances',
          column: 'event_id',
          value: eventId,
          orderBy: 'user_name',
          ascending: true,
        )
        .map((rows) => rows.map(_attendanceFromMap).toList());
  }

  @override
  Future<void> submitAttendance({
    required String eventId,
    required String userId,
    required String userName,
    required AttendanceStatus status,
    String reason = '',
  }) async {
    await _supabase.from('attendances').upsert(
      {
        'event_id': eventId,
        'user_uid': userId,
        'user_name': userName,
        'status': status.name,
        'reason': reason,
        'responded_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'event_id,user_uid',
    );
  }

  @override
  Future<Attendance?> getMyAttendance(String eventId, String userId) async {
    try {
      final data = await _supabase
          .from('attendances')
          .select()
          .eq('event_id', eventId)
          .eq('user_uid', userId)
          .maybeSingle();
      if (data == null) return null;
      return _attendanceFromMap(data);
    } on PostgrestException {
      return null;
    }
  }

  @override
  Future<AttendanceStats> getStats(String eventId) async {
    final data = await _supabase
        .from('attendances')
        .select()
        .eq('event_id', eventId);

    int aanwezig = 0, afwezig = 0, onzeker = 0;
    for (final row in data) {
      switch (row['status'] as String) {
        case 'aanwezig':
          aanwezig++;
        case 'afwezig':
          afwezig++;
        case 'onzeker':
          onzeker++;
      }
    }
    return AttendanceStats(
      aanwezig: aanwezig,
      afwezig: afwezig,
      onzeker: onzeker,
      total: data.length,
    );
  }

  @override
  Future<List<Attendance>> getUserHistory(
      String userId, String teamId) async {
    final data = await _supabase
        .from('attendances')
        .select('*, events!inner(team_id)')
        .eq('user_uid', userId)
        .eq('events.team_id', teamId)
        .order('responded_at', ascending: false);
    return data.map(_attendanceFromMap).toList();
  }

  Attendance _attendanceFromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'] as String,
      eventId: map['event_id'] as String,
      userUid: map['user_uid'] as String,
      userName: map['user_name'] as String,
      status: AttendanceStatus.values.byName(map['status'] as String),
      reason: map['reason'] as String? ?? '',
    );
  }
}
