import 'package:equatable/equatable.dart';

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
  });

  final String id;
  final String teamId;
  final String title;
  final EventType type;
  final DateTime dateTime;
  final String location;
  final String notes;

  TeamEvent copyWith({
    String? id,
    String? teamId,
    String? title,
    EventType? type,
    DateTime? dateTime,
    String? location,
    String? notes,
  }) {
    return TeamEvent(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      title: title ?? this.title,
      type: type ?? this.type,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props =>
      [id, teamId, title, type, dateTime, location, notes];
}