part of 'news_bloc.dart';

sealed class NewsEvent extends Equatable {
  const NewsEvent();

  @override
  List<Object?> get props => [];
}

final class NewsLoadRequested extends NewsEvent {
  const NewsLoadRequested({required this.clubId, required this.teamIds});
  final String clubId;
  final List<String> teamIds;

  @override
  List<Object?> get props => [clubId, teamIds];
}

final class NewsCreateRequested extends NewsEvent {
  const NewsCreateRequested({required this.post});
  final NewsPost post;

  @override
  List<Object?> get props => [post];
}

final class NewsDeleteRequested extends NewsEvent {
  const NewsDeleteRequested({required this.postId});
  final String postId;

  @override
  List<Object?> get props => [postId];
}
