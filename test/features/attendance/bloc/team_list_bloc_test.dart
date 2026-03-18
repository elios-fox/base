import 'package:base/core/models/team.dart';
import 'package:base/features/attendance/bloc/team_list_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/mocks.dart';

void main() {
  late MockTeamRepository mockTeamRepository;

  setUpAll(() {
    registerFallbackValue(fakeTeam());
  });

  setUp(() {
    mockTeamRepository = MockTeamRepository();
  });

  group('TeamListBloc', () {
    final teams = [
      Team(
        id: '1',
        name: 'Heren 1',
        ownerUid: 'u1',
        createdAt: DateTime(2026, 1, 1),
        memberUids: const ['u1'],
      ),
    ];

    blocTest<TeamListBloc, TeamListState>(
      'emits [loading, loaded] when TeamListLoadRequested succeeds',
      build: () {
        when(() => mockTeamRepository.teams('u1'))
            .thenAnswer((_) => Stream.value(teams));
        return TeamListBloc(teamRepository: mockTeamRepository);
      },
      act: (bloc) => bloc.add(const TeamListLoadRequested(userUid: 'u1')),
      expect: () => [
        const TeamListState(status: TeamListStatus.loading),
        TeamListState(status: TeamListStatus.loaded, teams: teams),
      ],
    );

    blocTest<TeamListBloc, TeamListState>(
      'emits [loading, loaded] with empty list when no teams',
      build: () {
        when(() => mockTeamRepository.teams('u1'))
            .thenAnswer((_) => Stream.value([]));
        return TeamListBloc(teamRepository: mockTeamRepository);
      },
      act: (bloc) => bloc.add(const TeamListLoadRequested(userUid: 'u1')),
      expect: () => [
        const TeamListState(status: TeamListStatus.loading),
        const TeamListState(status: TeamListStatus.loaded, teams: []),
      ],
    );

    blocTest<TeamListBloc, TeamListState>(
      'calls deleteTeam on TeamDeleteRequested',
      build: () {
        when(() => mockTeamRepository.deleteTeam('1'))
            .thenAnswer((_) async {});
        return TeamListBloc(teamRepository: mockTeamRepository);
      },
      act: (bloc) => bloc.add(const TeamDeleteRequested('1')),
      verify: (_) {
        verify(() => mockTeamRepository.deleteTeam('1')).called(1);
      },
    );

    blocTest<TeamListBloc, TeamListState>(
      'calls saveTeam on TeamCreateRequested',
      build: () {
        when(() => mockTeamRepository.saveTeam(any()))
            .thenAnswer((_) async {});
        return TeamListBloc(teamRepository: mockTeamRepository);
      },
      act: (bloc) =>
          bloc.add(const TeamCreateRequested(name: 'Test', ownerUid: 'u1')),
      verify: (_) {
        verify(() => mockTeamRepository.saveTeam(any())).called(1);
      },
    );

    test('initial state is correct', () {
      final bloc = TeamListBloc(teamRepository: mockTeamRepository);
      expect(bloc.state, const TeamListState());
      expect(bloc.state.status, TeamListStatus.initial);
      expect(bloc.state.teams, isEmpty);
    });
  });
}
