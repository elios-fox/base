import 'package:base/core/models/team_event.dart';
import 'package:base/features/attendance/bloc/event_list_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/mocks.dart';

void main() {
  late MockTeamRepository mockTeamRepository;

  setUpAll(() {
    registerFallbackValue(fakeEvent());
  });

  setUp(() {
    mockTeamRepository = MockTeamRepository();
  });

  group('EventListBloc', () {
    final events = [
      fakeEvent(id: '1', title: 'Training'),
      fakeEvent(
          id: '2', title: 'Wedstrijd', type: EventType.wedstrijd),
    ];

    blocTest<EventListBloc, EventListState>(
      'emits [loading, loaded] when EventListLoadRequested succeeds',
      build: () {
        when(() => mockTeamRepository.events('team-1'))
            .thenAnswer((_) => Stream.value(events));
        return EventListBloc(teamRepository: mockTeamRepository);
      },
      act: (bloc) =>
          bloc.add(const EventListLoadRequested(teamId: 'team-1')),
      expect: () => [
        const EventListState(status: EventListStatus.loading),
        EventListState(status: EventListStatus.loaded, events: events),
      ],
    );

    blocTest<EventListBloc, EventListState>(
      'calls saveEvent on EventCreateRequested',
      build: () {
        when(() => mockTeamRepository.saveEvent(any()))
            .thenAnswer((_) async {});
        return EventListBloc(teamRepository: mockTeamRepository);
      },
      act: (bloc) =>
          bloc.add(EventCreateRequested(event: fakeEvent())),
      verify: (_) {
        verify(() => mockTeamRepository.saveEvent(any())).called(1);
      },
    );

    blocTest<EventListBloc, EventListState>(
      'calls deleteEvent on EventDeleteRequested',
      build: () {
        when(() => mockTeamRepository.deleteEvent('1'))
            .thenAnswer((_) async {});
        return EventListBloc(teamRepository: mockTeamRepository);
      },
      act: (bloc) => bloc.add(const EventDeleteRequested('1')),
      verify: (_) {
        verify(() => mockTeamRepository.deleteEvent('1')).called(1);
      },
    );

    test('initial state is correct', () {
      final bloc = EventListBloc(teamRepository: mockTeamRepository);
      expect(bloc.state.status, EventListStatus.initial);
      expect(bloc.state.events, isEmpty);
    });
  });
}
