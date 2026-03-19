import 'package:base/core/auth/auth_bloc.dart';
import 'package:base/core/auth/auth_repository.dart';
import 'package:base/features/profile/bloc/profile_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });

  group('ProfileBloc', () {
    test('initial state is correct', () {
      when(() => mockAuthBloc.state).thenReturn(const AuthState.unknown());
      final bloc = ProfileBloc(authBloc: mockAuthBloc);
      expect(bloc.state, const ProfileState());
      expect(bloc.state.status, ProfileStatus.initial);
      expect(bloc.state.displayName, '');
      expect(bloc.state.email, '');
      expect(bloc.state.photoUrl, isNull);
    });

    blocTest<ProfileBloc, ProfileState>(
      'emits loaded state with user data when ProfileLoadRequested and user exists',
      build: () {
        when(() => mockAuthBloc.state).thenReturn(
          const AuthState.authenticated(
            AuthUser(
              uid: 'user-1',
              email: 'jan@example.com',
              displayName: 'Jan de Vries',
              photoUrl: 'https://example.com/photo.jpg',
            ),
          ),
        );
        return ProfileBloc(authBloc: mockAuthBloc);
      },
      act: (bloc) => bloc.add(const ProfileLoadRequested()),
      expect: () => [
        const ProfileState(
          status: ProfileStatus.loaded,
          displayName: 'Jan de Vries',
          email: 'jan@example.com',
          photoUrl: 'https://example.com/photo.jpg',
        ),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits loaded state with fallback displayName when user has no displayName',
      build: () {
        when(() => mockAuthBloc.state).thenReturn(
          const AuthState.authenticated(
            AuthUser(uid: 'user-1', email: 'jan@example.com'),
          ),
        );
        return ProfileBloc(authBloc: mockAuthBloc);
      },
      act: (bloc) => bloc.add(const ProfileLoadRequested()),
      expect: () => [
        const ProfileState(
          status: ProfileStatus.loaded,
          displayName: 'Onbekend',
          email: 'jan@example.com',
        ),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits nothing when ProfileLoadRequested and user is null',
      build: () {
        when(() => mockAuthBloc.state)
            .thenReturn(const AuthState.unauthenticated());
        return ProfileBloc(authBloc: mockAuthBloc);
      },
      act: (bloc) => bloc.add(const ProfileLoadRequested()),
      expect: () => <ProfileState>[],
    );
  });
}
