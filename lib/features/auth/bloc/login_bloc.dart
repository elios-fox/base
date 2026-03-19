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
    emit(state.copyWith(email: event.email));
  }

  void _onPasswordChanged(
    LoginPasswordChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(password: event.password));
  }

  void _onNameChanged(
    LoginNameChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(name: event.name));
  }

  Future<void> _onEmailSubmitted(
    LoginWithEmailSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.submitting));
    try {
      await _authRepository.signInWithEmailAndPassword(
        state.email,
        state.password,
      );
      emit(state.copyWith(status: LoginStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSignUpSubmitted(
    SignUpWithEmailSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.submitting));
    try {
      await _authRepository.createUserWithEmailAndPassword(
        state.email,
        state.password,
      );
      emit(state.copyWith(status: LoginStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onGooglePressed(
    LoginWithGooglePressed event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.submitting));
    try {
      await _authRepository.signInWithGoogle();
      emit(state.copyWith(status: LoginStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onApplePressed(
    LoginWithApplePressed event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.submitting));
    try {
      await _authRepository.signInWithApple();
      emit(state.copyWith(status: LoginStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

}
