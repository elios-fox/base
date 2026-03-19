import 'package:base/core/models/attendance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Attendance', () {
    test('supports value equality', () {
      const att1 = Attendance(
        id: '1',
        eventId: 'e1',
        userUid: 'u1',
        userName: 'Jan',
        status: AttendanceStatus.aanwezig,
      );
      const att2 = Attendance(
        id: '1',
        eventId: 'e1',
        userUid: 'u1',
        userName: 'Jan',
        status: AttendanceStatus.aanwezig,
      );
      expect(att1, equals(att2));
    });

    test('different status means not equal', () {
      const att1 = Attendance(
        id: '1',
        eventId: 'e1',
        userUid: 'u1',
        userName: 'Jan',
        status: AttendanceStatus.aanwezig,
      );
      const att2 = Attendance(
        id: '1',
        eventId: 'e1',
        userUid: 'u1',
        userName: 'Jan',
        status: AttendanceStatus.afwezig,
      );
      expect(att1, isNot(equals(att2)));
    });

    test('copyWith updates fields', () {
      const att = Attendance(
        id: '1',
        eventId: 'e1',
        userUid: 'u1',
        userName: 'Jan',
        status: AttendanceStatus.aanwezig,
      );
      final updated = att.copyWith(
        status: AttendanceStatus.afwezig,
        reason: 'Blessure',
      );

      expect(updated.status, AttendanceStatus.afwezig);
      expect(updated.reason, 'Blessure');
      expect(updated.id, '1');
      expect(updated.userName, 'Jan');
    });

    test('AttendanceStatus has correct values', () {
      expect(AttendanceStatus.values.length, 3);
      expect(AttendanceStatus.aanwezig.name, 'aanwezig');
      expect(AttendanceStatus.afwezig.name, 'afwezig');
      expect(AttendanceStatus.onzeker.name, 'onzeker');
    });
  });
}
