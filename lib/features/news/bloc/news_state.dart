part of 'news_bloc.dart';

enum NewsStatus { initial, loading, loaded, failure }

enum NewsCreateStatus { initial, submitting, success, failure }

final class NewsState extends Equatable {
  const NewsState({
    this.status = NewsStatus.initial,
    this.posts = const [],
    this.createStatus = NewsCreateStatus.initial,
    this.errorMessage,
  });

  final NewsStatus status;
  final List<NewsPost> posts;
  final NewsCreateStatus createStatus;
  final String? errorMessage;

  NewsState copyWith({
    NewsStatus? status,
    List<NewsPost>? posts,
    NewsCreateStatus? createStatus,
    String? errorMessage,
  }) {
    return NewsState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      createStatus: createStatus ?? this.createStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, posts, createStatus, errorMessage];
}
