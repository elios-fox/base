import 'package:base/core/auth/auth_repository.dart';
import 'package:base/features/auth/bloc/login_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository authRepository;

  setUp(() {
    authRepository = MockAuthRepository();
  });

  group('LoginBloc', () {
    test('initial state is correct', () {
      final bloc = LoginBloc(authRepository: authRepository);
      expect(bloc.state, const LoginState());
      bloc.close();
    });

    blocTest<LoginBloc, LoginState>(
      'emits updated email when LoginEmailChanged is added',
      build: () => LoginBloc(authRepository: authRepository),
      act: (bloc) => bloc.add(const LoginEmailChanged('test@example.com')),
      expect: () => [
        const LoginState(email: 'test@example.com'),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'emits updated password when LoginPasswordChanged is added',
      build: () => LoginBloc(authRepository: authRepository),
      act: (bloc) => bloc.add(const LoginPasswordChanged('password123')),
      expect: () => [
        const LoginState(password: 'password123'),
      ],
    );

    group('LoginWithEmailSubmitted', () {
      blocTest<LoginBloc, LoginState>(
        'emits [submitting, success] on successful sign in',
        build: () {
          when(() => authRepository.signInWithEmailAndPassword(
                any(),
                any(),
              )).thenAnswer((_) async {});
          return LoginBloc(authRepository: authRepository);
        },
        seed: () => const LoginState(
          email: 'test@example.com',
          password: 'password123',
        ),
        act: (bloc) => bloc.add(const LoginWithEmailSubmitted()),
        expect: () => [
          const LoginState(
            email: 'test@example.com',
            password: 'password123',
            status: LoginStatus.submitting,
          ),
          const LoginState(
            email: 'test@example.com',
            password: 'password123',
            status: LoginStatus.success,
          ),
        ],
      );

      blocTest<LoginBloc, LoginState>(
        'emits [submitting, failure] on failed sign in',
        build: () {
          when(() => authRepository.signInWithEmailAndPassword(
                any(),
                any(),
              )).thenThrow(Exception('Invalid credentials'));
          return LoginBloc(authRepository: authRepository);
        },
        seed: () => const LoginState(
          email: 'test@example.com',
          password: 'wrong',
        ),
        act: (bloc) => bloc.add(const LoginWithEmailSubmitted()),
        expect: () => [
          const LoginState(
            email: 'test@example.com',
            password: 'wrong',
            status: LoginStatus.submitting,
          ),
          const LoginState(
            email: 'test@example.com',
            password: 'wrong',
            status: LoginStatus.failure,
            errorMessage: 'Exception: Invalid credentials',
          ),
        ],
      );
    });

    group('SignUpWithEmailSubmitted', () {
      blocTest<LoginBloc, LoginState>(
        'emits [submitting, success] on successful sign up',
        build: () {
          when(() => authRepository.createUserWithEmailAndPassword(
                any(),
                any(),
              )).thenAnswer((_) async {});
          return LoginBloc(authRepository: authRepository);
        },
        seed: () => const LoginState(
          email: 'new@example.com',
          password: 'password123',
        ),
        act: (bloc) => bloc.add(const SignUpWithEmailSubmitted()),
        expect: () => [
          const LoginState(
            email: 'new@example.com',
            password: 'password123',
            status: LoginStatus.submitting,
          ),
          const LoginState(
            email: 'new@example.com',
            password: 'password123',
            status: LoginStatus.success,
          ),
        ],
      );
    });

    group('Social sign-in', () {
      blocTest<LoginBloc, LoginState>(
        'emits [submitting, success] on Google sign in',
        build: () {
          when(() => authRepository.signInWithGoogle())
              .thenAnswer((_) async {});
          return LoginBloc(authRepository: authRepository);
        },
        act: (bloc) => bloc.add(const LoginWithGooglePressed()),
        expect: () => [
          const LoginState(status: LoginStatus.submitting),
          const LoginState(status: LoginStatus.success),
        ],
      );

      blocTest<LoginBloc, LoginState>(
        'emits [submitting, failure] on Google sign in error',
        build: () {
          when(() => authRepository.signInWithGoogle())
              .thenThrow(Exception('Google sign-in aborted'));
          return LoginBloc(authRepository: authRepository);
        },
        act: (bloc) => bloc.add(const LoginWithGooglePressed()),
        expect: () => [
          const LoginState(status: LoginStatus.submitting),
          const LoginState(
            status: LoginStatus.failure,
            errorMessage: 'Exception: Google sign-in aborted',
          ),
        ],
      );

      blocTest<LoginBloc, LoginState>(
        'emits [submitting, success] on Apple sign in',
        build: () {
          when(() => authRepository.signInWithApple())
              .thenAnswer((_) async {});
          return LoginBloc(authRepository: authRepository);
        },
        act: (bloc) => bloc.add(const LoginWithApplePressed()),
        expect: () => [
          const LoginState(status: LoginStatus.submitting),
          const LoginState(status: LoginStatus.success),
        ],
      );

    });
  });
}
