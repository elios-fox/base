import 'package:equatable/equatable.dart';

class Team extends Equatable {
  const Team({
    required this.id,
    required this.name,
    required this.ownerUid,
    required this.createdAt,
    this.memberUids = const [],
    this.photoUrl,
    this.dominantColor,
  });

  final String id;
  final String name;
  final String ownerUid;
  final DateTime createdAt;
  final List<String> memberUids;
  final String? photoUrl;
  final String? dominantColor;

  Team copyWith({
    String? id,
    String? name,
    String? ownerUid,
    DateTime? createdAt,
    List<String>? memberUids,
    String? photoUrl,
    String? dominantColor,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerUid: ownerUid ?? this.ownerUid,
      createdAt: createdAt ?? this.createdAt,
      memberUids: memberUids ?? this.memberUids,
      photoUrl: photoUrl ?? this.photoUrl,
      dominantColor: dominantColor ?? this.dominantColor,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, ownerUid, createdAt, memberUids, photoUrl, dominantColor];
}
