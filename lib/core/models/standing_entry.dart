import 'package:equatable/equatable.dart';

/// Berekende stand-entry. Niet opgeslagen in de database,
/// maar berekend uit match_results.
class StandingEntry extends Equatable {
  const StandingEntry({
    required this.teamName,
    this.played = 0,
    this.won = 0,
    this.drawn = 0,
    this.lost = 0,
  });

  final String teamName;
  final int played;
  final int won;
  final int drawn;
  final int lost;

  /// Punten: W=3, G=1, V=0
  int get points => (won * 3) + drawn;

  StandingEntry copyWith({
    String? teamName,
    int? played,
    int? won,
    int? drawn,
    int? lost,
  }) {
    return StandingEntry(
      teamName: teamName ?? this.teamName,
      played: played ?? this.played,
      won: won ?? this.won,
      drawn: drawn ?? this.drawn,
      lost: lost ?? this.lost,
    );
  }

  @override
  List<Object?> get props => [teamName, played, won, drawn, lost];
}
