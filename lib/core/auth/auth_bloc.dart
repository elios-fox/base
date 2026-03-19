import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState.unknown()) {
    on<AuthSubscriptionRequested>(_onSubscriptionRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  final AuthRepository _authRepository;

  Future<void> _onSubscriptionRequested(
    AuthSubscriptionRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Check if there is already a session at startup.
    // This handles the case where the user was already logged in.
    final currentUser = _authRepository.currentUser;
    if (currentUser != null) {
      emit(AuthState.authenticated(currentUser));
    }

    // Then listen to the auth state change stream for future changes.
    // The stream will emit initialSession, signedIn, signedOut, etc.
    await emit.forEach<AuthUser?>(
      _authRepository.authStateChanges,
      onData: (user) {
        if (user != null) {
          return AuthState.authenticated(user);
        }
        return const AuthState.unauthenticated();
      },
      onError: (_, _) => const AuthState.unauthenticated(),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.signOut();
  }
}
