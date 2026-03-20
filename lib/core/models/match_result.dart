import 'package:equatable/equatable.dart';

class MatchResult extends Equatable {
  const MatchResult({
    required this.id,
    required this.eventId,
    required this.homeScore,
    required this.awayScore,
    required this.opponentName,
    required this.createdAt,
  });

  final String id;
  final String eventId;
  final int homeScore;
  final int awayScore;
  final String opponentName;
  final DateTime createdAt;

  MatchResult copyWith({
    String? id,
    String? eventId,
    int? homeScore,
    int? awayScore,
    String? opponentName,
    DateTime? createdAt,
  }) {
    return MatchResult(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      homeScore: homeScore ?? this.homeScore,
      awayScore: awayScore ?? this.awayScore,
      opponentName: opponentName ?? this.opponentName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory MatchResult.fromJson(Map<String, dynamic> json) {
    return MatchResult(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      homeScore: json['home_score'] as int,
      awayScore: json['away_score'] as int,
      opponentName: json['opponent_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'home_score': homeScore,
      'away_score': awayScore,
      'opponent_name': opponentName,
    };
  }

  /// Bepaal resultaat: 'W' (winst), 'G' (gelijk), 'V' (verlies)
  String get resultIndicator {
    if (homeScore > awayScore) return 'W';
    if (homeScore == awayScore) return 'G';
    return 'V';
  }

  @override
  List<Object?> get props => [
        id,
        eventId,
        homeScore,
        awayScore,
        opponentName,
        createdAt,
      ];
}
