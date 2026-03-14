import 'dart:async';

import 'package:base/core/auth/auth_bloc.dart';
import 'package:base/core/auth/auth_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository authRepository;

  const user = AuthUser(
    uid: 'test-uid',
    email: 'test@example.com',
    displayName: 'Test User',
  );

  setUp(() {
    authRepository = MockAuthRepository();
  });

  group('AuthBloc', () {
    test('initial state is AuthState.unknown', () {
      when(() => authRepository.authStateChanges)
          .thenAnswer((_) => const Stream.empty());
      final bloc = AuthBloc(authRepository: authRepository);
      expect(bloc.state, const AuthState.unknown());
      bloc.close();
    });

    blocTest<AuthBloc, AuthState>(
      'emits [unauthenticated] when auth state stream emits null',
      build: () {
        when(() => authRepository.authStateChanges)
            .thenAnswer((_) => Stream.value(null));
        return AuthBloc(authRepository: authRepository);
      },
      act: (bloc) => bloc.add(const AuthSubscriptionRequested()),
      expect: () => [const AuthState.unauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [authenticated] when auth state stream emits a user',
      build: () {
        when(() => authRepository.authStateChanges)
            .thenAnswer((_) => Stream.value(user));
        return AuthBloc(authRepository: authRepository);
      },
      act: (bloc) => bloc.add(const AuthSubscriptionRequested()),
      expect: () => [const AuthState.authenticated(user)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [unauthenticated] when auth state stream errors',
      build: () {
        when(() => authRepository.authStateChanges)
            .thenAnswer((_) => Stream.error(Exception('fail')));
        return AuthBloc(authRepository: authRepository);
      },
      act: (bloc) => bloc.add(const AuthSubscriptionRequested()),
      expect: () => [const AuthState.unauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'calls signOut when AuthLogoutRequested is added',
      build: () {
        when(() => authRepository.authStateChanges)
            .thenAnswer((_) => const Stream.empty());
        when(() => authRepository.signOut()).thenAnswer((_) async {});
        return AuthBloc(authRepository: authRepository);
      },
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      verify: (_) {
        verify(() => authRepository.signOut()).called(1);
      },
    );
  });
}
