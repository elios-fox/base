import 'package:equatable/equatable.dart';

enum ClubRole { bestuur, teamcaptain, speler }

class ClubMember extends Equatable {
  const ClubMember({
    required this.id,
    required this.clubId,
    required this.userUid,
    required this.role,
    required this.joinedAt,
    this.displayName,
    this.email,
  });

  final String id;
  final String clubId;
  final String userUid;
  final ClubRole role;
  final DateTime joinedAt;
  final String? displayName;
  final String? email;

  bool get isBestuur => role == ClubRole.bestuur;
  bool get isTeamcaptain => role == ClubRole.teamcaptain;
  bool get isSpeler => role == ClubRole.speler;

  ClubMember copyWith({
    String? id,
    String? clubId,
    String? userUid,
    ClubRole? role,
    DateTime? joinedAt,
    String? displayName,
    String? email,
  }) {
    return ClubMember(
      id: id ?? this.id,
      clubId: clubId ?? this.clubId,
      userUid: userUid ?? this.userUid,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
    );
  }

  @override
  List<Object?> get props =>
      [id, clubId, userUid, role, joinedAt, displayName, email];
}
