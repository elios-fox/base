import 'package:base/core/models/attendance.dart';
import 'package:base/features/attendance/bloc/event_detail_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/mocks.dart';

void main() {
  late MockAttendanceService mockAttendanceService;
  late MockEventService mockEventService;

  setUpAll(() {
    registerFallbackValue(fakeAttendance());
    registerFallbackValue(AttendanceStatus.aanwezig);
  });

  setUp(() {
    mockAttendanceService = MockAttendanceService();
    mockEventService = MockEventService();
  });

  EventDetailBloc buildBloc() => EventDetailBloc(
        attendanceService: mockAttendanceService,
        eventService: mockEventService,
      );

  group('EventDetailBloc', () {
    final attendances = [
      fakeAttendance(
          id: '1', userName: 'Jan', status: AttendanceStatus.aanwezig),
      fakeAttendance(
          id: '2',
          userName: 'Piet',
          userUid: 'u2',
          status: AttendanceStatus.afwezig),
      fakeAttendance(
          id: '3',
          userName: 'Klaas',
          userUid: 'u3',
          status: AttendanceStatus.onzeker),
    ];

    test('initial state is correct', () {
      final bloc = buildBloc();
      expect(bloc.state.status, EventDetailStatus.initial);
      expect(bloc.state.attendances, isEmpty);
      expect(bloc.state.event, isNull);
    });

    blocTest<EventDetailBloc, EventDetailState>(
      'emits [loading, loaded] when load succeeds without event',
      build: () {
        when(() => mockAttendanceService.getAttendances('event-1'))
            .thenAnswer((_) => Stream.value(attendances));
        when(() => mockEventService.getEvent('event-1'))
            .thenAnswer((_) async => null);
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const EventDetailLoadRequested(eventId: 'event-1')),
      expect: () => [
        const EventDetailState(status: EventDetailStatus.loading),
        EventDetailState(
          status: EventDetailStatus.loaded,
          attendances: attendances,
        ),
      ],
    );

    blocTest<EventDetailBloc, EventDetailState>(
      'uses passed event and does not call getEvent',
      build: () {
        when(() => mockAttendanceService.getAttendances('event-1'))
            .thenAnswer((_) => Stream.value([]));
        return buildBloc();
      },
      act: (bloc) => bloc.add(EventDetailLoadRequested(
        eventId: 'event-1',
        event: fakeEvent(),
      )),
      expect: () => [
        const EventDetailState(status: EventDetailStatus.loading),
        EventDetailState(
          status: EventDetailStatus.loading,
          event: fakeEvent(),
        ),
        EventDetailState(
          status: EventDetailStatus.loaded,
          event: fakeEvent(),
          attendances: const [],
        ),
      ],
      verify: (_) {
        verifyNever(() => mockEventService.getEvent(any()));
      },
    );

    blocTest<EventDetailBloc, EventDetailState>(
      'fetches event from service when event param is null',
      build: () {
        final event = fakeEvent(id: 'event-1', title: 'Fetched');
        when(() => mockEventService.getEvent('event-1'))
            .thenAnswer((_) async => event);
        when(() => mockAttendanceService.getAttendances('event-1'))
            .thenAnswer((_) => Stream.value([]));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const EventDetailLoadRequested(eventId: 'event-1')),
      expect: () => [
        const EventDetailState(status: EventDetailStatus.loading),
        EventDetailState(
          status: EventDetailStatus.loading,
          event: fakeEvent(id: 'event-1', title: 'Fetched'),
        ),
        EventDetailState(
          status: EventDetailStatus.loaded,
          event: fakeEvent(id: 'event-1', title: 'Fetched'),
          attendances: const [],
        ),
      ],
      verify: (_) {
        verify(() => mockEventService.getEvent('event-1')).called(1);
      },
    );

    blocTest<EventDetailBloc, EventDetailState>(
      'handles getEvent returning null gracefully',
      build: () {
        when(() => mockEventService.getEvent('event-1'))
            .thenAnswer((_) async => null);
        when(() => mockAttendanceService.getAttendances('event-1'))
            .thenAnswer((_) => Stream.value(attendances));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const EventDetailLoadRequested(eventId: 'event-1')),
      expect: () => [
        const EventDetailState(status: EventDetailStatus.loading),
        EventDetailState(
          status: EventDetailStatus.loaded,
          attendances: attendances,
        ),
      ],
    );

    test('attendance stats are calculated correctly', () {
      final state = EventDetailState(
        status: EventDetailStatus.loaded,
        attendances: attendances,
      );

      expect(state.aanwezigCount, 1);
      expect(state.afwezigCount, 1);
      expect(state.onzekerCount, 1);
    });

    blocTest<EventDetailBloc, EventDetailState>(
      'calls submitAttendance on AttendanceSubmitted',
      build: () {
        when(() => mockAttendanceService.submitAttendance(
              eventId: any(named: 'eventId'),
              userId: any(named: 'userId'),
              userName: any(named: 'userName'),
              status: any(named: 'status'),
              reason: any(named: 'reason'),
            )).thenAnswer((_) async {});
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AttendanceSubmitted(
        eventId: 'event-1',
        userUid: 'user-1',
        userName: 'Jan',
        status: AttendanceStatus.aanwezig,
      )),
      verify: (_) {
        verify(() => mockAttendanceService.submitAttendance(
              eventId: 'event-1',
              userId: 'user-1',
              userName: 'Jan',
              status: AttendanceStatus.aanwezig,
              reason: '',
            )).called(1);
      },
    );

    group('EventDetailLoadRequested props', () {
      test('includes event in props', () {
        final event = fakeEvent();
        final a = EventDetailLoadRequested(eventId: 'e1', event: event);
        final b = EventDetailLoadRequested(eventId: 'e1', event: event);
        expect(a, equals(b));
      });

      test('events with different event are not equal', () {
        final a = EventDetailLoadRequested(
            eventId: 'e1', event: fakeEvent(title: 'A'));
        final b = EventDetailLoadRequested(
            eventId: 'e1', event: fakeEvent(title: 'B'));
        expect(a, isNot(equals(b)));
      });
    });
  });
}
