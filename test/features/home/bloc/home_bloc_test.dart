import 'package:base/core/models/team.dart';
import 'package:base/features/home/bloc/home_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  late MockTeamService mockTeamService;
  late MockEventService mockEventService;

  setUp(() {
    mockTeamService = MockTeamService();
    mockEventService = MockEventService();
  });

  group('HomeBloc', () {
    test('initial state is correct', () {
      when(() => mockTeamService.getTeams(any()))
          .thenAnswer((_) => const Stream.empty());
      final bloc = HomeBloc(
        teamService: mockTeamService,
        eventService: mockEventService,
        userId: 'test-user',
        displayName: 'Test',
      );
      expect(bloc.state, const HomeState());
      bloc.close();
    });

    blocTest<HomeBloc, HomeState>(
      'emits [loading, success] when HomeStarted is added',
      build: () {
        when(() => mockTeamService.getTeams(any()))
            .thenAnswer((_) => Stream.value(<Team>[]));
        when(() => mockEventService.getUpcomingEvents(any()))
            .thenAnswer((_) async => []);
        return HomeBloc(
          teamService: mockTeamService,
          eventService: mockEventService,
          userId: 'test-user',
          displayName: 'Test',
        );
      },
      act: (bloc) => bloc.add(const HomeStarted()),
      wait: const Duration(milliseconds: 500),
      expect: () => [
        isA<HomeState>().having((s) => s.status, 'status', HomeStatus.loading),
        isA<HomeState>()
            .having((s) => s.status, 'status', HomeStatus.success)
            .having((s) => s.greeting, 'greeting', contains('Test')),
      ],
    );
  });
}
