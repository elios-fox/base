import 'package:base/core/models/team_event.dart';
import 'package:base/features/attendance/bloc/event_list_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/mocks.dart';

void main() {
  late MockEventService mockEventService;

  setUpAll(() {
    registerFallbackValue(fakeEvent());
  });

  setUp(() {
    mockEventService = MockEventService();
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
        when(() => mockEventService.getEvents('team-1'))
            .thenAnswer((_) => Stream.value(events));
        return EventListBloc(eventService: mockEventService);
      },
      act: (bloc) =>
          bloc.add(const EventListLoadRequested(teamId: 'team-1')),
      expect: () => [
        const EventListState(status: EventListStatus.loading),
        EventListState(status: EventListStatus.loaded, events: events),
      ],
    );

    blocTest<EventListBloc, EventListState>(
      'calls createEvent on EventCreateRequested',
      build: () {
        when(() => mockEventService.createEvent(any()))
            .thenAnswer((_) async => fakeEvent());
        return EventListBloc(eventService: mockEventService);
      },
      act: (bloc) =>
          bloc.add(EventCreateRequested(event: fakeEvent())),
      verify: (_) {
        verify(() => mockEventService.createEvent(any())).called(1);
      },
    );

    blocTest<EventListBloc, EventListState>(
      'calls deleteEvent on EventDeleteRequested',
      build: () {
        when(() => mockEventService.deleteEvent('1'))
            .thenAnswer((_) async {});
        return EventListBloc(eventService: mockEventService);
      },
      act: (bloc) => bloc.add(const EventDeleteRequested('1')),
      verify: (_) {
        verify(() => mockEventService.deleteEvent('1')).called(1);
      },
    );

    blocTest<EventListBloc, EventListState>(
      'emits [failure, loaded] when createEvent throws — recovers for retry',
      build: () {
        when(() => mockEventService.createEvent(any()))
            .thenThrow(Exception('Supabase error'));
        return EventListBloc(eventService: mockEventService);
      },
      seed: () => EventListState(status: EventListStatus.loaded, events: [fakeEvent()]),
      act: (bloc) =>
          bloc.add(EventCreateRequested(event: fakeEvent())),
      expect: () => [
        EventListState(status: EventListStatus.failure, events: [fakeEvent()]),
        EventListState(status: EventListStatus.loaded, events: [fakeEvent()]),
      ],
    );

    test('initial state is correct', () {
      final bloc = EventListBloc(eventService: mockEventService);
      expect(bloc.state.status, EventListStatus.initial);
      expect(bloc.state.events, isEmpty);
    });
  });
}
