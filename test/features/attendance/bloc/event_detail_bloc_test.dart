import 'package:base/core/models/attendance.dart';
import 'package:base/features/attendance/bloc/event_detail_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/mocks.dart';

void main() {
  late MockAttendanceService mockAttendanceService;

  setUpAll(() {
    registerFallbackValue(fakeAttendance());
    registerFallbackValue(AttendanceStatus.aanwezig);
  });

  setUp(() {
    mockAttendanceService = MockAttendanceService();
  });

  group('EventDetailBloc', () {
    final attendances = [
      fakeAttendance(id: '1', userName: 'Jan', status: AttendanceStatus.aanwezig),
      fakeAttendance(id: '2', userName: 'Piet', userUid: 'u2', status: AttendanceStatus.afwezig),
      fakeAttendance(id: '3', userName: 'Klaas', userUid: 'u3', status: AttendanceStatus.onzeker),
    ];

    blocTest<EventDetailBloc, EventDetailState>(
      'emits [loading, loaded] when EventDetailLoadRequested succeeds',
      build: () {
        when(() => mockAttendanceService.getAttendances('event-1'))
            .thenAnswer((_) => Stream.value(attendances));
        return EventDetailBloc(attendanceService: mockAttendanceService);
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
        return EventDetailBloc(attendanceService: mockAttendanceService);
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

    test('initial state is correct', () {
      final bloc = EventDetailBloc(attendanceService: mockAttendanceService);
      expect(bloc.state.status, EventDetailStatus.initial);
      expect(bloc.state.attendances, isEmpty);
      expect(bloc.state.event, isNull);
    });
  });
}
