import 'package:equatable/equatable.dart';

enum RecurringFrequency { weekly, biweekly }

class RecurringPattern extends Equatable {
  const RecurringPattern({
    required this.frequency,
    required this.dayOfWeek,
    required this.endDate,
  });

  /// Frequentie: wekelijks of tweewekelijks
  final RecurringFrequency frequency;

  /// Dag van de week (1=maandag, 7=zondag, conform DateTime.weekday)
  final int dayOfWeek;

  /// Einddatum van de reeks
  final DateTime endDate;

  RecurringPattern copyWith({
    RecurringFrequency? frequency,
    int? dayOfWeek,
    DateTime? endDate,
  }) {
    return RecurringPattern(
      frequency: frequency ?? this.frequency,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      endDate: endDate ?? this.endDate,
    );
  }

  factory RecurringPattern.fromJson(Map<String, dynamic> json) {
    return RecurringPattern(
      frequency: RecurringFrequency.values.firstWhere(
        (e) => e.name == json['frequency'],
      ),
      dayOfWeek: json['day_of_week'] as int,
      endDate: DateTime.parse(json['end_date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'frequency': frequency.name,
      'day_of_week': dayOfWeek,
      'end_date': endDate.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [frequency, dayOfWeek, endDate];
}
