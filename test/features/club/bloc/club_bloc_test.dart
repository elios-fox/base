import 'package:base/core/models/club.dart';
import 'package:base/core/models/club_member.dart';
import 'package:base/features/club/bloc/club_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  late MockClubService clubService;

  const testUserId = 'user-jan-123';

  final testClub = Club(
    id: 'club-1',
    name: 'SC Oranje',
    inviteCode: 'ORANJE2024',
    createdAt: DateTime(2024, 1, 15),
  );

  final testClub2 = Club(
    id: 'club-2',
    name: 'HC De Tulpen',
    inviteCode: 'TULPEN99',
    createdAt: DateTime(2024, 3, 10),
  );

  final testMembers = [
    ClubMember(
      id: 'member-1',
      clubId: 'club-1',
      userUid: testUserId,
      displayName: 'Jan de Vries',
      role: ClubRole.bestuur,
      joinedAt: DateTime(2024, 1, 15),
    ),
    ClubMember(
      id: 'member-2',
      clubId: 'club-1',
      userUid: 'user-piet-456',
      displayName: 'Piet Bakker',
      role: ClubRole.teamcaptain,
      joinedAt: DateTime(2024, 2, 1),
    ),
    ClubMember(
      id: 'member-3',
      clubId: 'club-1',
      userUid: 'user-kees-789',
      displayName: 'Kees van Dijk',
      role: ClubRole.speler,
      joinedAt: DateTime(2024, 3, 5),
    ),
  ];

  setUpAll(() {
    registerFallbackValue(ClubRole.speler);
  });

  setUp(() {
    clubService = MockClubService();
  });

  ClubBloc buildBloc() => ClubBloc(
        clubService: clubService,
        userId: testUserId,
      );

  group('ClubBloc', () {
    test('initial state is correct', () {
      when(() => clubService.getMyClubs(any()))
          .thenAnswer((_) => const Stream.empty());
      final bloc = buildBloc();
      expect(bloc.state, const ClubState());
      expect(bloc.state.status, ClubStatus.initial);
      expect(bloc.state.clubs, isEmpty);
      expect(bloc.state.selectedClub, isNull);
      expect(bloc.state.members, isEmpty);
      expect(bloc.state.myMembership, isNull);
      expect(bloc.state.errorMessage, isNull);
      bloc.close();
    });

    group('ClubLoadRequested', () {
      blocTest<ClubBloc, ClubState>(
        'emits [loading, loaded] when ClubLoadRequested succeeds',
        build: () {
          when(() => clubService.getMyClubs(any()))
              .thenAnswer((_) => Stream.value([testClub, testClub2]));
          return buildBloc();
        },
        act: (bloc) => bloc.add(const ClubLoadRequested()),
        expect: () => [
          const ClubState(status: ClubStatus.loading),
          ClubState(
            status: ClubStatus.loaded,
            clubs: [testClub, testClub2],
          ),
        ],
      );

      blocTest<ClubBloc, ClubState>(
        'emits [loading, failure] when ClubLoadRequested fails',
        build: () {
          when(() => clubService.getMyClubs(any()))
              .thenAnswer((_) => Stream.error(Exception('Verbinding mislukt')));
          return buildBloc();
        },
        act: (bloc) => bloc.add(const ClubLoadRequested()),
        expect: () => [
          const ClubState(status: ClubStatus.loading),
          const ClubState(status: ClubStatus.failure),
        ],
      );
    });

    group('ClubCreateRequested', () {
      blocTest<ClubBloc, ClubState>(
        'emits [submitting, success, initial] when ClubCreateRequested succeeds',
        build: () {
          when(() => clubService.createClub(any(), any()))
              .thenAnswer((_) async => testClub);
          return buildBloc();
        },
        act: (bloc) => bloc.add(const ClubCreateRequested(
          name: 'SC Oranje',
        )),
        expect: () => [
          const ClubState(createStatus: ClubCreateStatus.submitting),
          const ClubState(createStatus: ClubCreateStatus.success),
          const ClubState(createStatus: ClubCreateStatus.initial),
        ],
        verify: (_) {
          verify(() => clubService.createClub('SC Oranje', testUserId))
              .called(1);
        },
      );

      blocTest<ClubBloc, ClubState>(
        'emits [submitting, failure] when ClubCreateRequested fails',
        build: () {
          when(() => clubService.createClub(any(), any()))
              .thenThrow(Exception('Naam al in gebruik'));
          return buildBloc();
        },
        act: (bloc) => bloc.add(const ClubCreateRequested(
          name: 'SC Oranje',
        )),
        expect: () => [
          const ClubState(createStatus: ClubCreateStatus.submitting),
          isA<ClubState>()
              .having(
                  (s) => s.createStatus, 'createStatus', ClubCreateStatus.failure)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                isNotNull,
              ),
        ],
      );
    });

    group('ClubJoinRequested', () {
      blocTest<ClubBloc, ClubState>(
        'emits [submitting, success, initial] when ClubJoinRequested succeeds',
        build: () {
          when(() => clubService.joinClub(any()))
              .thenAnswer((_) async => testClub2);
          return buildBloc();
        },
        act: (bloc) => bloc.add(
          const ClubJoinRequested(inviteCode: 'TULPEN99'),
        ),
        expect: () => [
          const ClubState(createStatus: ClubCreateStatus.submitting),
          const ClubState(createStatus: ClubCreateStatus.success),
          const ClubState(createStatus: ClubCreateStatus.initial),
        ],
        verify: (_) {
          verify(() => clubService.joinClub('TULPEN99')).called(1);
        },
      );

      blocTest<ClubBloc, ClubState>(
        'emits [submitting, failure] when ClubJoinRequested fails with invalid code',
        build: () {
          when(() => clubService.joinClub(any()))
              .thenThrow(Exception('Ongeldige uitnodigingscode'));
          return buildBloc();
        },
        act: (bloc) => bloc.add(
          const ClubJoinRequested(inviteCode: 'ONGELDIG'),
        ),
        expect: () => [
          const ClubState(createStatus: ClubCreateStatus.submitting),
          isA<ClubState>()
              .having(
                  (s) => s.createStatus, 'createStatus', ClubCreateStatus.failure)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                isNotNull,
              ),
        ],
      );
    });

    group('ClubDetailLoadRequested', () {
      blocTest<ClubBloc, ClubState>(
        'emits state with selectedClub when ClubDetailLoadRequested succeeds',
        build: () {
          when(() => clubService.getClub(any()))
              .thenAnswer((_) async => testClub);
          return buildBloc();
        },
        act: (bloc) => bloc.add(
          const ClubDetailLoadRequested(clubId: 'club-1'),
        ),
        expect: () => [
          ClubState(selectedClub: testClub),
        ],
        verify: (_) {
          verify(() => clubService.getClub('club-1')).called(1);
        },
      );
    });

    group('ClubMembersLoadRequested', () {
      blocTest<ClubBloc, ClubState>(
        'emits state with members when ClubMembersLoadRequested succeeds',
        build: () {
          when(() => clubService.getClubMembers(any()))
              .thenAnswer((_) => Stream.value(testMembers));
          return buildBloc();
        },
        act: (bloc) => bloc.add(
          const ClubMembersLoadRequested(clubId: 'club-1'),
        ),
        expect: () => [
          ClubState(
            members: testMembers,
            myMembership: testMembers[0], // Jan de Vries = bestuur = testUserId
          ),
        ],
        verify: (_) {
          verify(() => clubService.getClubMembers('club-1')).called(1);
        },
      );

      blocTest<ClubBloc, ClubState>(
        'identifies myMembership from members list',
        build: () {
          when(() => clubService.getClubMembers(any()))
              .thenAnswer((_) => Stream.value(testMembers));
          return buildBloc();
        },
        act: (bloc) => bloc.add(
          const ClubMembersLoadRequested(clubId: 'club-1'),
        ),
        verify: (bloc) {
          expect(bloc.state.myMembership, isNotNull);
          expect(bloc.state.myMembership!.userUid, testUserId);
          expect(bloc.state.myMembership!.displayName, 'Jan de Vries');
          expect(bloc.state.myMembership!.role, ClubRole.bestuur);
        },
      );
    });

    group('ClubMemberRoleChanged', () {
      blocTest<ClubBloc, ClubState>(
        'calls updateMemberRole on ClubMemberRoleChanged',
        build: () {
          when(() => clubService.updateMemberRole(any(), any()))
              .thenAnswer((_) async {});
          return buildBloc();
        },
        act: (bloc) => bloc.add(const ClubMemberRoleChanged(
          memberId: 'member-3',
          newRole: ClubRole.teamcaptain,
        )),
        verify: (_) {
          verify(() => clubService.updateMemberRole(
                'member-3',
                ClubRole.teamcaptain,
              )).called(1);
        },
      );
    });

    group('ClubMemberRemoved', () {
      blocTest<ClubBloc, ClubState>(
        'calls removeMember on ClubMemberRemoved',
        build: () {
          when(() => clubService.removeMember(any()))
              .thenAnswer((_) async {});
          return buildBloc();
        },
        act: (bloc) => bloc.add(
          const ClubMemberRemoved(memberId: 'member-3'),
        ),
        verify: (_) {
          verify(() => clubService.removeMember('member-3')).called(1);
        },
      );
    });
  });
}
