import 'package:equatable/equatable.dart';

import 'checklist_item.dart';

class Checklist extends Equatable {
  const Checklist({
    required this.id,
    required this.title,
    required this.ownerUid,
    required this.createdAt,
    this.items = const [],
  });

  final String id;
  final String title;
  final String ownerUid;
  final DateTime createdAt;
  final List<ChecklistItem> items;

  Checklist copyWith({
    String? id,
    String? title,
    String? ownerUid,
    DateTime? createdAt,
    List<ChecklistItem>? items,
  }) {
    return Checklist(
      id: id ?? this.id,
      title: title ?? this.title,
      ownerUid: ownerUid ?? this.ownerUid,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [id, title, ownerUid, createdAt, items];
}
