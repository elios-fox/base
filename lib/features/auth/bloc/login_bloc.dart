import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/auth/auth_repository.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const LoginState()) {
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginNameChanged>(_onNameChanged);
    on<LoginWithEmailSubmitted>(_onEmailSubmitted);
    on<SignUpWithEmailSubmitted>(_onSignUpSubmitted);
    on<LoginWithGooglePressed>(_onGooglePressed);
    on<LoginWithApplePressed>(_onApplePressed);
  }

  final AuthRepository _authRepository;

  void _onEmailChanged(LoginEmailChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(email: event.email, clearError: true));
  }

  void _onPasswordChanged(
    LoginPasswordChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(password: event.password, clearError: true));
  }

  void _onNameChanged(
    LoginNameChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(name: event.name, clearError: true));
  }

  Future<void> _onEmailSubmitted(
    LoginWithEmailSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (state.email.isEmpty || state.password.isEmpty) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'Vul je e-mailadres en wachtwoord in.',
      ));
      return;
    }

    emit(state.copyWith(status: LoginStatus.submitting, clearError: true));
    try {
      await _authRepository.signInWithEmailAndPassword(
        state.email,
        state.password,
      );
      emit(state.copyWith(status: LoginStatus.success));
    } on AuthError catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'Er is een fout opgetreden. Probeer het opnieuw.',
      ));
    }
  }

  Future<void> _onSignUpSubmitted(
    SignUpWithEmailSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (state.email.isEmpty || state.password.isEmpty) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'Vul je e-mailadres en wachtwoord in.',
      ));
      return;
    }

    emit(state.copyWith(status: LoginStatus.submitting, clearError: true));
    try {
      final result = await _authRepository.createUserWithEmailAndPassword(
        state.email,
        state.password,
        name: state.name.isNotEmpty ? state.name : null,
      );

      switch (result) {
        case SignUpResult.authenticated:
          emit(state.copyWith(status: LoginStatus.success));
        case SignUpResult.needsEmailConfirmation:
          emit(state.copyWith(status: LoginStatus.emailConfirmationSent));
      }
    } on AuthError catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'Registratie is mislukt. Probeer het opnieuw.',
      ));
    }
  }

  Future<void> _onGooglePressed(
    LoginWithGooglePressed event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.submitting, clearError: true));
    try {
      await _authRepository.signInWithGoogle();
      // OAuth opens an external browser. The actual sign-in will be handled
      // by the auth state change stream when the user returns to the app.
      // Reset to initial so the UI is not stuck in "submitting" state.
      emit(state.copyWith(status: LoginStatus.initial, clearError: true));
    } on AuthError catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'Inloggen met Google is mislukt. Probeer het opnieuw.',
      ));
    }
  }

  Future<void> _onApplePressed(
    LoginWithApplePressed event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.submitting, clearError: true));
    try {
      await _authRepository.signInWithApple();
      // OAuth opens an external browser. Reset to initial state.
      emit(state.copyWith(status: LoginStatus.initial, clearError: true));
    } on AuthError catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'Inloggen met Apple is mislukt. Probeer het opnieuw.',
      ));
    }
  }
}
