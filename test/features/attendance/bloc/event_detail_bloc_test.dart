import 'package:base/core/models/attendance.dart';
import 'package:base/features/attendance/bloc/event_detail_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/mocks.dart';

void main() {
  late MockTeamRepository mockTeamRepository;

  setUpAll(() {
    registerFallbackValue(fakeAttendance());
  });

  setUp(() {
    mockTeamRepository = MockTeamRepository();
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
        when(() => mockTeamRepository.attendances('event-1'))
            .thenAnswer((_) => Stream.value(attendances));
        return EventDetailBloc(teamRepository: mockTeamRepository);
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
      'calls saveAttendance with composite ID on AttendanceSubmitted',
      build: () {
        when(() => mockTeamRepository.saveAttendance(any()))
            .thenAnswer((_) async {});
        return EventDetailBloc(teamRepository: mockTeamRepository);
      },
      act: (bloc) => bloc.add(const AttendanceSubmitted(
        eventId: 'event-1',
        userUid: 'user-1',
        userName: 'Jan',
        status: AttendanceStatus.aanwezig,
      )),
      verify: (_) {
        final captured = verify(
          () => mockTeamRepository.saveAttendance(captureAny()),
        ).captured;
        final attendance = captured.first as Attendance;
        expect(attendance.id, 'event-1_user-1');
        expect(attendance.status, AttendanceStatus.aanwezig);
      },
    );

    test('initial state is correct', () {
      final bloc = EventDetailBloc(teamRepository: mockTeamRepository);
      expect(bloc.state.status, EventDetailStatus.initial);
      expect(bloc.state.attendances, isEmpty);
      expect(bloc.state.event, isNull);
    });
  });
}
