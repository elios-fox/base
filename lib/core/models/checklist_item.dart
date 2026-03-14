import 'package:equatable/equatable.dart';

class ChecklistItem extends Equatable {
  const ChecklistItem({
    required this.id,
    required this.title,
    this.description = '',
    this.photoUrl,
    required this.order,
  });

  final String id;
  final String title;
  final String description;
  final String? photoUrl;
  final int order;

  ChecklistItem copyWith({
    String? id,
    String? title,
    String? description,
    String? Function()? photoUrl,
    int? order,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      photoUrl: photoUrl != null ? photoUrl() : this.photoUrl,
      order: order ?? this.order,
    );
  }

  factory ChecklistItem.fromMap(Map<String, dynamic> map) {
    return ChecklistItem(
      id: map['id'] as String,
      title: map['title'] as String,
      description: (map['description'] as String?) ?? '',
      photoUrl: map['photoUrl'] as String?,
      order: map['order'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'photoUrl': photoUrl,
      'order': order,
    };
  }

  @override
  List<Object?> get props => [id, title, description, photoUrl, order];
}
