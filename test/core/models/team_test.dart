import 'package:base/core/models/team.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Team', () {
    test('supports value equality', () {
      final team1 = Team(
        id: '1',
        name: 'Heren 1',
        ownerUid: 'u1',
        createdAt: DateTime(2026, 1, 1),
        memberUids: const ['u1', 'u2'],
      );
      final team2 = Team(
        id: '1',
        name: 'Heren 1',
        ownerUid: 'u1',
        createdAt: DateTime(2026, 1, 1),
        memberUids: const ['u1', 'u2'],
      );
      expect(team1, equals(team2));
    });

    test('different teams are not equal', () {
      final team1 = Team(
        id: '1',
        name: 'Heren 1',
        ownerUid: 'u1',
        createdAt: DateTime(2026, 1, 1),
      );
      final team2 = Team(
        id: '2',
        name: 'Dames 1',
        ownerUid: 'u1',
        createdAt: DateTime(2026, 1, 1),
      );
      expect(team1, isNot(equals(team2)));
    });

    test('copyWith creates a copy with updated fields', () {
      final team = Team(
        id: '1',
        name: 'Heren 1',
        ownerUid: 'u1',
        createdAt: DateTime(2026, 1, 1),
        memberUids: const ['u1'],
      );
      final updated = team.copyWith(name: 'Heren 2');

      expect(updated.name, 'Heren 2');
      expect(updated.id, '1');
      expect(updated.ownerUid, 'u1');
    });

    test('copyWith with no arguments returns identical team', () {
      final team = Team(
        id: '1',
        name: 'Heren 1',
        ownerUid: 'u1',
        createdAt: DateTime(2026, 1, 1),
      );
      expect(team.copyWith(), equals(team));
    });

  });
}
