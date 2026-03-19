import 'package:base/features/attendance/bloc/team_detail_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/mocks.dart';

void main() {
  late MockTeamService mockTeamService;
  late MockStorageService mockStorageService;

  setUpAll(() {
    registerFallbackValue(fakeTeam());
  });

  setUp(() {
    mockTeamService = MockTeamService();
    mockStorageService = MockStorageService();
  });

  TeamDetailBloc buildBloc() => TeamDetailBloc(
        teamService: mockTeamService,
        storageService: mockStorageService,
      );

  group('TeamDetailBloc', () {
    test('initial state is correct', () {
      final bloc = buildBloc();
      expect(bloc.state, const TeamDetailState());
      expect(bloc.state.status, TeamDetailStatus.initial);
      expect(bloc.state.team, isNull);
      expect(bloc.state.codeCopied, false);
    });

    blocTest<TeamDetailBloc, TeamDetailState>(
      'emits [loading, loaded] when TeamDetailLoadRequested succeeds',
      build: () {
        final team = fakeTeam();
        when(() => mockTeamService.getTeam('team-1'))
            .thenAnswer((_) async => team);
        return buildBloc();
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
        when(() => mockTeamService.getTeam('team-1'))
            .thenThrow(Exception('not found'));
        return buildBloc();
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
        when(() => mockTeamService.updateTeam(any()))
            .thenAnswer((_) async {});
        return buildBloc();
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
          () => mockTeamService.updateTeam(captureAny()),
        ).captured;
        final savedTeam = captured.first;
        expect(savedTeam.memberUids, ['user-1', 'user-3']);
      },
    );

    blocTest<TeamDetailBloc, TeamDetailState>(
      'does nothing on TeamDetailMemberRemoved when team is null',
      build: () => buildBloc(),
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
      build: () => buildBloc(),
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
