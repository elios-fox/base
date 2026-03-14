import 'package:cloud_firestore/cloud_firestore.dart';
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

  factory Checklist.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final itemsList = (data['items'] as List<dynamic>?)
            ?.map((e) => ChecklistItem.fromMap(e as Map<String, dynamic>))
            .toList() ??
        [];
    return Checklist(
      id: doc.id,
      title: data['title'] as String,
      ownerUid: data['ownerUid'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      items: itemsList,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'ownerUid': ownerUid,
      'createdAt': Timestamp.fromDate(createdAt),
      'items': items.map((e) => e.toMap()).toList(),
    };
  }

  @override
  List<Object?> get props => [id, title, ownerUid, createdAt, items];
}
