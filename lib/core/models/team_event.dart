import 'package:equatable/equatable.dart';

import 'recurring_pattern.dart';

enum EventType { training, wedstrijd }

class TeamEvent extends Equatable {
  const TeamEvent({
    required this.id,
    required this.teamId,
    required this.title,
    required this.type,
    required this.dateTime,
    this.location = '',
    this.notes = '',
    this.recurring = false,
    this.recurringPattern,
  });

  final String id;
  final String teamId;
  final String title;
  final EventType type;
  final DateTime dateTime;
  final String location;
  final String notes;
  final bool recurring;
  final RecurringPattern? recurringPattern;

  bool get isWedstrijd => type == EventType.wedstrijd;

  TeamEvent copyWith({
    String? id,
    String? teamId,
    String? title,
    EventType? type,
    DateTime? dateTime,
    String? location,
    String? notes,
    bool? recurring,
    RecurringPattern? recurringPattern,
  }) {
    return TeamEvent(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      title: title ?? this.title,
      type: type ?? this.type,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      recurring: recurring ?? this.recurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
    );
  }

  @override
  List<Object?> get props =>
      [id, teamId, title, type, dateTime, location, notes, recurring, recurringPattern];
}
