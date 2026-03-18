import 'package:pocketbase/pocketbase.dart';

import '../core/models/attendance.dart';
import '../core/pocketbase/pb_client.dart';
import '../core/pocketbase/pb_realtime.dart';

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

class PbAttendanceService implements AttendanceService {
  PbAttendanceService({PbClient? client, PbRealtime? realtime})
      : _client = client ?? PbClient.instance,
        _realtime = realtime ?? PbRealtime();

  final PbClient _client;
  final PbRealtime _realtime;

  PocketBase get _pb => _client.pb;

  @override
  Stream<List<Attendance>> getAttendances(String eventId) {
    return _realtime
        .subscribeToList(
          'attendances',
          filter: 'eventId = "$eventId"',
          sort: 'userName',
        )
        .map((records) => records.map(_attendanceFromRecord).toList());
  }

  @override
  Future<void> submitAttendance({
    required String eventId,
    required String userId,
    required String userName,
    required AttendanceStatus status,
    String reason = '',
  }) async {
    // Check of er al een attendance bestaat
    try {
      final existing = await _pb.collection('attendances').getFirstListItem(
            'eventId = "$eventId" && userUid = "$userId"',
          );
      // Update bestaande
      await _pb.collection('attendances').update(existing.id, body: {
        'status': status.name,
        'reason': reason,
        'respondedAt': DateTime.now().toUtc().toIso8601String(),
      });
    } on ClientException {
      // Nieuwe attendance aanmaken
      await _pb.collection('attendances').create(body: {
        'eventId': eventId,
        'userUid': userId,
        'userName': userName,
        'status': status.name,
        'reason': reason,
        'respondedAt': DateTime.now().toUtc().toIso8601String(),
      });
    }
  }

  @override
  Future<Attendance?> getMyAttendance(String eventId, String userId) async {
    try {
      final record = await _pb.collection('attendances').getFirstListItem(
            'eventId = "$eventId" && userUid = "$userId"',
          );
      return _attendanceFromRecord(record);
    } on ClientException {
      return null;
    }
  }

  @override
  Future<AttendanceStats> getStats(String eventId) async {
    final records = await _pb.collection('attendances').getFullList(
          filter: 'eventId = "$eventId"',
        );

    int aanwezig = 0, afwezig = 0, onzeker = 0;
    for (final record in records) {
      switch (record.getStringValue('status')) {
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
      total: records.length,
    );
  }

  @override
  Future<List<Attendance>> getUserHistory(
      String userId, String teamId) async {
    final records = await _pb.collection('attendances').getFullList(
          filter: 'userUid = "$userId"',
          sort: '-respondedAt',
          expand: 'eventId',
        );
    return records.map(_attendanceFromRecord).toList();
  }

  Attendance _attendanceFromRecord(RecordModel record) {
    return Attendance(
      id: record.id,
      eventId: record.getStringValue('eventId'),
      userUid: record.getStringValue('userUid'),
      userName: record.getStringValue('userName'),
      status: AttendanceStatus.values.byName(record.getStringValue('status')),
      reason: record.getStringValue('reason'),
    );
  }
}
