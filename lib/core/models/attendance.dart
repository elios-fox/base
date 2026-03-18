import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum AttendanceStatus { aanwezig, afwezig, onzeker }

class Attendance extends Equatable {
  const Attendance({
    required this.id,
    required this.eventId,
    required this.userUid,
    required this.userName,
    required this.status,
    this.reason = '',
  });

  final String id;
  final String eventId;
  final String userUid;
  final String userName;
  final AttendanceStatus status;
  final String reason;

  Attendance copyWith({
    String? id,
    String? eventId,
    String? userUid,
    String? userName,
    AttendanceStatus? status,
    String? reason,
  }) {
    return Attendance(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      userUid: userUid ?? this.userUid,
      userName: userName ?? this.userName,
      status: status ?? this.status,
      reason: reason ?? this.reason,
    );
  }

  factory Attendance.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Attendance(
      id: doc.id,
      eventId: data['eventId'] as String,
      userUid: data['userUid'] as String,
      userName: data['userName'] as String,
      status: AttendanceStatus.values.byName(data['status'] as String),
      reason: data['reason'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'eventId': eventId,
      'userUid': userUid,
      'userName': userName,
      'status': status.name,
      'reason': reason,
    };
  }

  @override
  List<Object?> get props => [id, eventId, userUid, userName, status, reason];
}