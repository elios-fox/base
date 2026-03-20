import 'package:equatable/equatable.dart';

class Team extends Equatable {
  const Team({
    required this.id,
    required this.name,
    required this.ownerUid,
    required this.createdAt,
    this.clubId,
    this.memberUids = const [],
    this.photoUrl,
    this.dominantColor,
    this.sport,
    this.seasonYear,
    this.inviteCode,
  });

  final String id;
  final String name;
  final String ownerUid;
  final DateTime createdAt;
  final String? clubId;
  final List<String> memberUids;
  final String? photoUrl;
  final String? dominantColor;
  final String? sport;
  final int? seasonYear;
  final String? inviteCode;

  Team copyWith({
    String? id,
    String? name,
    String? ownerUid,
    DateTime? createdAt,
    String? clubId,
    List<String>? memberUids,
    String? photoUrl,
    String? dominantColor,
    String? sport,
    int? seasonYear,
    String? inviteCode,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerUid: ownerUid ?? this.ownerUid,
      createdAt: createdAt ?? this.createdAt,
      clubId: clubId ?? this.clubId,
      memberUids: memberUids ?? this.memberUids,
      photoUrl: photoUrl ?? this.photoUrl,
      dominantColor: dominantColor ?? this.dominantColor,
      sport: sport ?? this.sport,
      seasonYear: seasonYear ?? this.seasonYear,
      inviteCode: inviteCode ?? this.inviteCode,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        ownerUid,
        createdAt,
        clubId,
        memberUids,
        photoUrl,
        dominantColor,
        sport,
        seasonYear,
        inviteCode,
      ];
}
