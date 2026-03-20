import 'package:equatable/equatable.dart';

class Club extends Equatable {
  const Club({
    required this.id,
    required this.name,
    required this.createdAt,
    this.logoUrl,
    this.inviteCode,
  });

  final String id;
  final String name;
  final DateTime createdAt;
  final String? logoUrl;
  final String? inviteCode;

  Club copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    String? logoUrl,
    String? inviteCode,
  }) {
    return Club(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      logoUrl: logoUrl ?? this.logoUrl,
      inviteCode: inviteCode ?? this.inviteCode,
    );
  }

  @override
  List<Object?> get props => [id, name, createdAt, logoUrl, inviteCode];
}
