import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/auth/auth_bloc.dart';

// Events
sealed class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

final class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

// State
enum ProfileStatus { initial, loaded }

final class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.displayName = '',
    this.email = '',
    this.photoUrl,
  });

  final ProfileStatus status;
  final String displayName;
  final String email;
  final String? photoUrl;

  ProfileState copyWith({
    ProfileStatus? status,
    String? displayName,
    String? email,
    String? photoUrl,
  }) {
    return ProfileState(
      status: status ?? this.status,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  List<Object?> get props => [status, displayName, email, photoUrl];
}

// Bloc
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({required AuthBloc authBloc})
      : _authBloc = authBloc,
        super(const ProfileState()) {
    on<ProfileLoadRequested>(_onLoadRequested);
  }

  final AuthBloc _authBloc;

  void _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) {
    final user = _authBloc.state.user;
    if (user != null) {
      emit(state.copyWith(
        status: ProfileStatus.loaded,
        displayName: user.displayName ?? 'Onbekend',
        email: user.email ?? '',
        photoUrl: user.photoUrl,
      ));
    }
  }
}
