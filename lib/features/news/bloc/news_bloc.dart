import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/news_post.dart';
import '../../../services/news_service.dart';

part 'news_event.dart';
part 'news_state.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  NewsBloc({required NewsService newsService})
      : _newsService = newsService,
        super(const NewsState()) {
    on<NewsLoadRequested>(_onLoadRequested);
    on<NewsCreateRequested>(_onCreateRequested);
    on<NewsDeleteRequested>(_onDeleteRequested);
  }

  final NewsService _newsService;

  Future<void> _onLoadRequested(
    NewsLoadRequested event,
    Emitter<NewsState> emit,
  ) async {
    emit(state.copyWith(status: NewsStatus.loading));
    await emit.forEach<List<NewsPost>>(
      _newsService.getNewsFeed(event.clubId, event.teamIds),
      onData: (posts) => state.copyWith(
        status: NewsStatus.loaded,
        posts: posts,
      ),
      onError: (_, __) => state.copyWith(status: NewsStatus.failure),
    );
  }

  Future<void> _onCreateRequested(
    NewsCreateRequested event,
    Emitter<NewsState> emit,
  ) async {
    emit(state.copyWith(createStatus: NewsCreateStatus.submitting));
    try {
      await _newsService.createPost(event.post);
      emit(state.copyWith(createStatus: NewsCreateStatus.success));
      emit(state.copyWith(createStatus: NewsCreateStatus.initial));
    } catch (e) {
      emit(state.copyWith(
        createStatus: NewsCreateStatus.failure,
        errorMessage: 'Kon bericht niet plaatsen.',
      ));
    }
  }

  Future<void> _onDeleteRequested(
    NewsDeleteRequested event,
    Emitter<NewsState> emit,
  ) async {
    try {
      await _newsService.deletePost(event.postId);
    } catch (_) {}
  }
}
