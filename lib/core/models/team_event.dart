import 'package:cloud_firestore/cloud_firestore.dart';
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

  factory TeamEvent.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return TeamEvent(
      id: doc.id,
      teamId: data['teamId'] as String,
      title: data['title'] as String,
      type: EventType.values.byName(data['type'] as String),
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      location: data['location'] as String? ?? '',
      notes: data['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'teamId': teamId,
      'title': title,
      'type': type.name,
      'dateTime': Timestamp.fromDate(dateTime),
      'location': location,
      'notes': notes,
    };
  }

  @override
  List<Object?> get props =>
      [id, teamId, title, type, dateTime, location, notes];
}