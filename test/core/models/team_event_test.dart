import 'package:base/core/models/team_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TeamEvent', () {
    test('supports value equality', () {
      final event1 = TeamEvent(
        id: '1',
        teamId: 't1',
        title: 'Training',
        type: EventType.training,
        dateTime: DateTime(2026, 3, 20, 19, 0),
        location: 'Sportpark',
      );
      final event2 = TeamEvent(
        id: '1',
        teamId: 't1',
        title: 'Training',
        type: EventType.training,
        dateTime: DateTime(2026, 3, 20, 19, 0),
        location: 'Sportpark',
      );
      expect(event1, equals(event2));
    });

    test('copyWith updates fields', () {
      final event = TeamEvent(
        id: '1',
        teamId: 't1',
        title: 'Training',
        type: EventType.training,
        dateTime: DateTime(2026, 3, 20, 19, 0),
      );
      final updated = event.copyWith(
        title: 'Wedstrijd',
        type: EventType.wedstrijd,
      );

      expect(updated.title, 'Wedstrijd');
      expect(updated.type, EventType.wedstrijd);
      expect(updated.id, '1');
      expect(updated.teamId, 't1');
    });

    test('toFirestore returns correct map', () {
      final event = TeamEvent(
        id: '1',
        teamId: 't1',
        title: 'Training',
        type: EventType.training,
        dateTime: DateTime(2026, 3, 20, 19, 0),
        location: 'Sportpark',
        notes: 'Neem scheenbeschermers mee',
      );
      final map = event.toFirestore();

      expect(map['teamId'], 't1');
      expect(map['title'], 'Training');
      expect(map['type'], 'training');
      expect(map['location'], 'Sportpark');
      expect(map['notes'], 'Neem scheenbeschermers mee');
    });

    test('EventType has correct values', () {
      expect(EventType.values.length, 2);
      expect(EventType.training.name, 'training');
      expect(EventType.wedstrijd.name, 'wedstrijd');
    });
  });
}
