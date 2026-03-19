import 'package:base/core/models/team.dart';
import 'package:base/features/attendance/bloc/team_list_bloc.dart';
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
        when(() => mockTeamService.getTeams('u1'))
            .thenAnswer((_) => Stream.value(teams));
        return TeamListBloc(teamService: mockTeamService);
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
        when(() => mockTeamService.getTeams('u1'))
            .thenAnswer((_) => Stream.value([]));
        return TeamListBloc(teamService: mockTeamService);
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
        when(() => mockTeamService.deleteTeam('1'))
            .thenAnswer((_) async {});
        return TeamListBloc(teamService: mockTeamService);
      },
      act: (bloc) => bloc.add(const TeamDeleteRequested('1')),
      verify: (_) {
        verify(() => mockTeamService.deleteTeam('1')).called(1);
      },
    );

    blocTest<TeamListBloc, TeamListState>(
      'calls createTeam on TeamCreateRequested',
      build: () {
        when(() => mockTeamService.createTeam(any(), any(), any()))
            .thenAnswer((_) async => fakeTeam());
        return TeamListBloc(teamService: mockTeamService);
      },
      act: (bloc) =>
          bloc.add(const TeamCreateRequested(name: 'Test', ownerUid: 'u1')),
      verify: (_) {
        verify(() => mockTeamService.createTeam('Test', 'u1', '')).called(1);
      },
    );

    test('initial state is correct', () {
      final bloc = TeamListBloc(teamService: mockTeamService);
      expect(bloc.state, const TeamListState());
      expect(bloc.state.status, TeamListStatus.initial);
      expect(bloc.state.teams, isEmpty);
    });
  });
}
