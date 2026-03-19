import 'package:base/features/attendance/bloc/join_team_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/mocks.dart';

void main() {
  late MockTeamService mockTeamService;

  setUpAll(() {
    registerFallbackValue(fakeTeam());
  });

  setUp(() {
    mockTeamService = MockTeamService();
  });

  group('JoinTeamBloc', () {
    test('initial state is correct', () {
      final bloc = JoinTeamBloc(teamService: mockTeamService);
      expect(bloc.state, const JoinTeamState());
      expect(bloc.state.status, JoinTeamStatus.initial);
      expect(bloc.state.code, '');
      expect(bloc.state.teamName, '');
      expect(bloc.state.errorMessage, isNull);
    });

    blocTest<JoinTeamBloc, JoinTeamState>(
      'emits state with updated code when JoinTeamCodeChanged is added',
      build: () => JoinTeamBloc(teamService: mockTeamService),
      act: (bloc) => bloc.add(const JoinTeamCodeChanged('ABC123')),
      expect: () => [
        const JoinTeamState(code: 'ABC123', status: JoinTeamStatus.initial),
      ],
    );

    blocTest<JoinTeamBloc, JoinTeamState>(
      'emits failure with error message when code is empty on submit',
      build: () => JoinTeamBloc(teamService: mockTeamService),
      act: (bloc) => bloc.add(const JoinTeamSubmitted(userUid: 'user-1')),
      expect: () => [
        const JoinTeamState(
          status: JoinTeamStatus.failure,
          errorMessage: 'Voer een code in.',
        ),
      ],
    );

    blocTest<JoinTeamBloc, JoinTeamState>(
      'emits failure with error message when code is only whitespace on submit',
      build: () => JoinTeamBloc(teamService: mockTeamService),
      seed: () => const JoinTeamState(code: '   '),
      act: (bloc) => bloc.add(const JoinTeamSubmitted(userUid: 'user-1')),
      expect: () => [
        const JoinTeamState(
          code: '   ',
          status: JoinTeamStatus.failure,
          errorMessage: 'Voer een code in.',
        ),
      ],
    );

    blocTest<JoinTeamBloc, JoinTeamState>(
      'emits [submitting, success] when code is valid and submit succeeds',
      build: () {
        when(() => mockTeamService.joinTeam('ABC123'))
            .thenAnswer((_) async => fakeTeam(name: 'Heren 1'));
        return JoinTeamBloc(teamService: mockTeamService);
      },
      seed: () => const JoinTeamState(code: 'ABC123'),
      act: (bloc) => bloc.add(const JoinTeamSubmitted(userUid: 'user-1')),
      expect: () => [
        const JoinTeamState(
          code: 'ABC123',
          status: JoinTeamStatus.submitting,
        ),
        const JoinTeamState(
          code: 'ABC123',
          status: JoinTeamStatus.success,
          teamName: 'Heren 1',
          teamId: 'team-1',
        ),
      ],
    );
  });
}
