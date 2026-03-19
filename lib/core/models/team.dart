import 'package:equatable/equatable.dart';

class Team extends Equatable {
  const Team({
    required this.id,
    required this.name,
    required this.ownerUid,
    required this.createdAt,
    this.memberUids = const [],
  });

  final String id;
  final String name;
  final String ownerUid;
  final DateTime createdAt;
  final List<String> memberUids;

  Team copyWith({
    String? id,
    String? name,
    String? ownerUid,
    DateTime? createdAt,
    List<String>? memberUids,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerUid: ownerUid ?? this.ownerUid,
      createdAt: createdAt ?? this.createdAt,
      memberUids: memberUids ?? this.memberUids,
    );
  }

  @override
  List<Object?> get props => [id, name, ownerUid, createdAt, memberUids];
}
