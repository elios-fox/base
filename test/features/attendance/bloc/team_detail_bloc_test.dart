import 'package:base/features/attendance/bloc/team_detail_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/services.dart';
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

  group('TeamDetailBloc', () {
    test('initial state is correct', () {
      final bloc = TeamDetailBloc(teamRepository: mockTeamRepository);
      expect(bloc.state, const TeamDetailState());
      expect(bloc.state.status, TeamDetailStatus.initial);
      expect(bloc.state.team, isNull);
      expect(bloc.state.codeCopied, false);
    });

    blocTest<TeamDetailBloc, TeamDetailState>(
      'emits [loading, loaded] when TeamDetailLoadRequested succeeds',
      build: () {
        final team = fakeTeam();
        when(() => mockTeamRepository.getTeam('team-1'))
            .thenAnswer((_) async => team);
        return TeamDetailBloc(teamRepository: mockTeamRepository);
      },
      act: (bloc) => bloc.add(const TeamDetailLoadRequested('team-1')),
      expect: () => [
        const TeamDetailState(status: TeamDetailStatus.loading),
        TeamDetailState(status: TeamDetailStatus.loaded, team: fakeTeam()),
      ],
    );

    blocTest<TeamDetailBloc, TeamDetailState>(
      'emits [loading, failure] when TeamDetailLoadRequested fails',
      build: () {
        when(() => mockTeamRepository.getTeam('team-1'))
            .thenThrow(Exception('not found'));
        return TeamDetailBloc(teamRepository: mockTeamRepository);
      },
      act: (bloc) => bloc.add(const TeamDetailLoadRequested('team-1')),
      expect: () => [
        const TeamDetailState(status: TeamDetailStatus.loading),
        const TeamDetailState(status: TeamDetailStatus.failure),
      ],
    );

    blocTest<TeamDetailBloc, TeamDetailState>(
      'removes member and saves updated team on TeamDetailMemberRemoved',
      build: () {
        when(() => mockTeamRepository.saveTeam(any()))
            .thenAnswer((_) async {});
        return TeamDetailBloc(teamRepository: mockTeamRepository);
      },
      seed: () => TeamDetailState(
        status: TeamDetailStatus.loaded,
        team: fakeTeam(memberUids: ['user-1', 'user-2', 'user-3']),
      ),
      act: (bloc) => bloc.add(const TeamDetailMemberRemoved(
        teamId: 'team-1',
        memberUid: 'user-2',
      )),
      expect: () => [
        TeamDetailState(
          status: TeamDetailStatus.loaded,
          team: fakeTeam(memberUids: ['user-1', 'user-3']),
        ),
      ],
      verify: (_) {
        final captured = verify(
          () => mockTeamRepository.saveTeam(captureAny()),
        ).captured;
        final savedTeam = captured.first;
        expect(savedTeam.memberUids, ['user-1', 'user-3']);
      },
    );

    blocTest<TeamDetailBloc, TeamDetailState>(
      'does nothing on TeamDetailMemberRemoved when team is null',
      build: () => TeamDetailBloc(teamRepository: mockTeamRepository),
      act: (bloc) => bloc.add(const TeamDetailMemberRemoved(
        teamId: 'team-1',
        memberUid: 'user-2',
      )),
      expect: () => <TeamDetailState>[],
    );

    blocTest<TeamDetailBloc, TeamDetailState>(
      'emits codeCopied true then false on TeamDetailInviteCodeCopied',
      setUp: () {
        TestWidgetsFlutterBinding.ensureInitialized();
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          SystemChannels.platform,
          (MethodCall methodCall) async {
            return null;
          },
        );
      },
      tearDown: () {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null);
      },
      build: () => TeamDetailBloc(teamRepository: mockTeamRepository),
      act: (bloc) =>
          bloc.add(const TeamDetailInviteCodeCopied('INVITE-CODE-123')),
      wait: const Duration(seconds: 3),
      expect: () => [
        const TeamDetailState(codeCopied: true),
        const TeamDetailState(codeCopied: false),
      ],
    );
  });
}
