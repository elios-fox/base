import 'package:equatable/equatable.dart';

class Contribution extends Equatable {
  const Contribution({
    required this.id,
    required this.teamId,
    required this.seasonYear,
    required this.amountCents,
    required this.description,
    required this.dueDate,
    required this.createdAt,
  });

  final String id;
  final String teamId;
  final int seasonYear;
  final int amountCents;
  final String description;
  final DateTime dueDate;
  final DateTime createdAt;

  double get amountEuros => amountCents / 100;

  Contribution copyWith({
    String? id,
    String? teamId,
    int? seasonYear,
    int? amountCents,
    String? description,
    DateTime? dueDate,
    DateTime? createdAt,
  }) {
    return Contribution(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      seasonYear: seasonYear ?? this.seasonYear,
      amountCents: amountCents ?? this.amountCents,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Contribution.fromJson(Map<String, dynamic> json) {
    return Contribution(
      id: json['id'] as String,
      teamId: json['team_id'] as String,
      seasonYear: json['season_year'] as int,
      amountCents: json['amount_cents'] as int,
      description: json['description'] as String? ?? '',
      dueDate: DateTime.parse(json['due_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'team_id': teamId,
      'season_year': seasonYear,
      'amount_cents': amountCents,
      'description': description,
      'due_date': dueDate.toIso8601String().split('T').first,
    };
  }

  @override
  List<Object?> get props => [
        id,
        teamId,
        seasonYear,
        amountCents,
        description,
        dueDate,
        createdAt,
      ];
}
