import 'package:equatable/equatable.dart';

class NewsPost extends Equatable {
  const NewsPost({
    required this.id,
    required this.authorUid,
    required this.title,
    required this.body,
    required this.createdAt,
    this.clubId,
    this.teamId,
    this.imageUrl,
    this.authorName,
  });

  final String id;
  final String? clubId;
  final String? teamId;
  final String authorUid;
  final String title;
  final String body;
  final String? imageUrl;
  final DateTime createdAt;
  final String? authorName;

  bool get isClubWide => clubId != null && teamId == null;

  NewsPost copyWith({
    String? id,
    String? clubId,
    String? teamId,
    String? authorUid,
    String? title,
    String? body,
    String? imageUrl,
    DateTime? createdAt,
    String? authorName,
  }) {
    return NewsPost(
      id: id ?? this.id,
      clubId: clubId ?? this.clubId,
      teamId: teamId ?? this.teamId,
      authorUid: authorUid ?? this.authorUid,
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      authorName: authorName ?? this.authorName,
    );
  }

  @override
  List<Object?> get props =>
      [id, clubId, teamId, authorUid, title, body, imageUrl, createdAt, authorName];
}
