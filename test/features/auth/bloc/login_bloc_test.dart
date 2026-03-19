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
              )).thenThrow(
            const AuthError('Onjuist e-mailadres of wachtwoord.'),
          );
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
            errorMessage: 'Onjuist e-mailadres of wachtwoord.',
          ),
        ],
      );

      blocTest<LoginBloc, LoginState>(
        'emits failure when email or password is empty',
        build: () => LoginBloc(authRepository: authRepository),
        seed: () => const LoginState(email: '', password: ''),
        act: (bloc) => bloc.add(const LoginWithEmailSubmitted()),
        expect: () => [
          const LoginState(
            status: LoginStatus.failure,
            errorMessage: 'Vul je e-mailadres en wachtwoord in.',
          ),
        ],
      );
    });

    group('SignUpWithEmailSubmitted', () {
      blocTest<LoginBloc, LoginState>(
        'emits [submitting, success] when email confirmation is not required',
        build: () {
          when(() => authRepository.createUserWithEmailAndPassword(
                any(),
                any(),
              )).thenAnswer((_) async => SignUpResult.authenticated);
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

      blocTest<LoginBloc, LoginState>(
        'emits [submitting, emailConfirmationSent] when email confirmation is required',
        build: () {
          when(() => authRepository.createUserWithEmailAndPassword(
                any(),
                any(),
              )).thenAnswer(
            (_) async => SignUpResult.needsEmailConfirmation,
          );
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
            status: LoginStatus.emailConfirmationSent,
          ),
        ],
      );
    });

    group('Social sign-in', () {
      blocTest<LoginBloc, LoginState>(
        'emits [submitting, initial] on Google sign in (opens external browser)',
        build: () {
          when(() => authRepository.signInWithGoogle())
              .thenAnswer((_) async {});
          return LoginBloc(authRepository: authRepository);
        },
        act: (bloc) => bloc.add(const LoginWithGooglePressed()),
        expect: () => [
          const LoginState(status: LoginStatus.submitting),
          const LoginState(status: LoginStatus.initial),
        ],
      );

      blocTest<LoginBloc, LoginState>(
        'emits [submitting, failure] on Google sign in error',
        build: () {
          when(() => authRepository.signInWithGoogle()).thenThrow(
            const AuthError(
                'Inloggen met Google is mislukt. Probeer het opnieuw.'),
          );
          return LoginBloc(authRepository: authRepository);
        },
        act: (bloc) => bloc.add(const LoginWithGooglePressed()),
        expect: () => [
          const LoginState(status: LoginStatus.submitting),
          const LoginState(
            status: LoginStatus.failure,
            errorMessage:
                'Inloggen met Google is mislukt. Probeer het opnieuw.',
          ),
        ],
      );

      blocTest<LoginBloc, LoginState>(
        'emits [submitting, initial] on Apple sign in (opens external browser)',
        build: () {
          when(() => authRepository.signInWithApple())
              .thenAnswer((_) async {});
          return LoginBloc(authRepository: authRepository);
        },
        act: (bloc) => bloc.add(const LoginWithApplePressed()),
        expect: () => [
          const LoginState(status: LoginStatus.submitting),
          const LoginState(status: LoginStatus.initial),
        ],
      );
    });
  });
}
