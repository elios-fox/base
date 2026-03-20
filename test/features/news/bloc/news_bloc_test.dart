import 'package:base/core/models/news_post.dart';
import 'package:base/features/news/bloc/news_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  late MockNewsService newsService;

  final testPost1 = NewsPost(
    id: 'post-1',
    clubId: 'club-1',
    authorUid: 'user-jan-123',
    authorName: 'Jan de Vries',
    title: 'Zaterdag oefenwedstrijd',
    body: 'Aanstaande zaterdag spelen we een oefenwedstrijd tegen HC De Tulpen. '
        'Verzamelen om 09:00 bij het clubhuis.',
    createdAt: DateTime(2024, 6, 10, 14, 30),
  );

  final testPost2 = NewsPost(
    id: 'post-2',
    clubId: 'club-1',
    authorUid: 'user-piet-456',
    authorName: 'Piet Bakker',
    title: 'Nieuwe tenues beschikbaar',
    body: 'De nieuwe tenues zijn binnen! Kom ze ophalen bij het bestuurskantoor.',
    imageUrl: 'https://example.com/tenues.jpg',
    createdAt: DateTime(2024, 6, 12, 10, 0),
  );

  setUpAll(() {
    registerFallbackValue(testPost1);
  });

  setUp(() {
    newsService = MockNewsService();
  });

  NewsBloc buildBloc() => NewsBloc(newsService: newsService);

  group('NewsBloc', () {
    test('initial state is correct', () {
      final bloc = buildBloc();
      expect(bloc.state, const NewsState());
      expect(bloc.state.status, NewsStatus.initial);
      expect(bloc.state.posts, isEmpty);
      expect(bloc.state.errorMessage, isNull);
      bloc.close();
    });

    group('NewsLoadRequested', () {
      blocTest<NewsBloc, NewsState>(
        'emits [loading, loaded] when NewsLoadRequested succeeds',
        build: () {
          when(() => newsService.getNewsFeed(any(), any()))
              .thenAnswer((_) => Stream.value([testPost1, testPost2]));
          return buildBloc();
        },
        act: (bloc) => bloc.add(
          const NewsLoadRequested(clubId: 'club-1', teamIds: []),
        ),
        expect: () => [
          const NewsState(status: NewsStatus.loading),
          NewsState(
            status: NewsStatus.loaded,
            posts: [testPost1, testPost2],
          ),
        ],
        verify: (_) {
          verify(() => newsService.getNewsFeed('club-1', [])).called(1);
        },
      );

      blocTest<NewsBloc, NewsState>(
        'emits [loading, failure] when NewsLoadRequested fails',
        build: () {
          when(() => newsService.getNewsFeed(any(), any()))
              .thenAnswer((_) => Stream.error(Exception('Nieuws laden mislukt')));
          return buildBloc();
        },
        act: (bloc) => bloc.add(
          const NewsLoadRequested(clubId: 'club-1', teamIds: []),
        ),
        expect: () => [
          const NewsState(status: NewsStatus.loading),
          const NewsState(status: NewsStatus.failure),
        ],
      );
    });

    group('NewsCreateRequested', () {
      blocTest<NewsBloc, NewsState>(
        'emits [submitting, success, initial] when NewsCreateRequested succeeds',
        build: () {
          when(() => newsService.createPost(any()))
              .thenAnswer((_) async => testPost1);
          return buildBloc();
        },
        act: (bloc) => bloc.add(NewsCreateRequested(
          post: testPost1,
        )),
        expect: () => [
          const NewsState(createStatus: NewsCreateStatus.submitting),
          const NewsState(createStatus: NewsCreateStatus.success),
          const NewsState(createStatus: NewsCreateStatus.initial),
        ],
        verify: (_) {
          verify(() => newsService.createPost(any())).called(1);
        },
      );

      blocTest<NewsBloc, NewsState>(
        'emits [submitting, failure] when NewsCreateRequested fails',
        build: () {
          when(() => newsService.createPost(any()))
              .thenThrow(Exception('Bericht aanmaken mislukt'));
          return buildBloc();
        },
        act: (bloc) => bloc.add(NewsCreateRequested(
          post: testPost1,
        )),
        expect: () => [
          const NewsState(createStatus: NewsCreateStatus.submitting),
          isA<NewsState>()
              .having((s) => s.createStatus, 'createStatus',
                  NewsCreateStatus.failure)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                isNotNull,
              ),
        ],
      );
    });

    group('NewsDeleteRequested', () {
      blocTest<NewsBloc, NewsState>(
        'calls deletePost when NewsDeleteRequested is added',
        build: () {
          when(() => newsService.deletePost(any()))
              .thenAnswer((_) async {});
          return buildBloc();
        },
        act: (bloc) => bloc.add(
          const NewsDeleteRequested(postId: 'post-1'),
        ),
        verify: (_) {
          verify(() => newsService.deletePost('post-1')).called(1);
        },
      );
    });
  });
}
