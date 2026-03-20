import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/auth/auth_bloc.dart';
import '../../../core/auth/auth_repository.dart';
import '../../../core/supabase/supabase_storage.dart';

// Events
sealed class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

final class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

final class ProfileNameChanged extends ProfileEvent {
  const ProfileNameChanged({required this.name});
  final String name;

  @override
  List<Object?> get props => [name];
}

final class ProfilePasswordChanged extends ProfileEvent {
  const ProfilePasswordChanged({required this.newPassword});
  final String newPassword;

  @override
  List<Object?> get props => [newPassword];
}

final class ProfilePhotoChanged extends ProfileEvent {
  const ProfilePhotoChanged({required this.photo});
  final File photo;

  @override
  List<Object?> get props => [photo];
}

// State
enum ProfileStatus { initial, loaded }

enum ProfileUpdateStatus { initial, submitting, success, failure }

final class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.displayName = '',
    this.email = '',
    this.photoUrl,
    this.updateStatus = ProfileUpdateStatus.initial,
    this.errorMessage,
    this.successMessage,
    this.isUploadingPhoto = false,
  });

  final ProfileStatus status;
  final String displayName;
  final String email;
  final String? photoUrl;
  final ProfileUpdateStatus updateStatus;
  final String? errorMessage;
  final String? successMessage;
  final bool isUploadingPhoto;

  ProfileState copyWith({
    ProfileStatus? status,
    String? displayName,
    String? email,
    String? photoUrl,
    ProfileUpdateStatus? updateStatus,
    String? errorMessage,
    String? successMessage,
    bool? isUploadingPhoto,
  }) {
    return ProfileState(
      status: status ?? this.status,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      updateStatus: updateStatus ?? this.updateStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      isUploadingPhoto: isUploadingPhoto ?? this.isUploadingPhoto,
    );
  }

  @override
  List<Object?> get props => [
        status,
        displayName,
        email,
        photoUrl,
        updateStatus,
        errorMessage,
        successMessage,
        isUploadingPhoto,
      ];
}

// Bloc
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required AuthBloc authBloc,
    required AuthRepository authRepository,
    StorageService? storageService,
  })  : _authBloc = authBloc,
        _authRepository = authRepository,
        _storageService = storageService,
        super(const ProfileState()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileNameChanged>(_onNameChanged);
    on<ProfilePasswordChanged>(_onPasswordChanged);
    on<ProfilePhotoChanged>(_onPhotoChanged);
  }

  final AuthBloc _authBloc;
  final AuthRepository _authRepository;
  final StorageService? _storageService;

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

  Future<void> _onNameChanged(
    ProfileNameChanged event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(updateStatus: ProfileUpdateStatus.submitting));
    try {
      await _authRepository.updateDisplayName(event.name);
      emit(state.copyWith(
        updateStatus: ProfileUpdateStatus.success,
        displayName: event.name,
        successMessage: 'Naam gewijzigd!',
      ));
      emit(state.copyWith(updateStatus: ProfileUpdateStatus.initial));
    } on AuthError catch (e) {
      emit(state.copyWith(
        updateStatus: ProfileUpdateStatus.failure,
        errorMessage: e.message,
      ));
      emit(state.copyWith(updateStatus: ProfileUpdateStatus.initial));
    }
  }

  Future<void> _onPasswordChanged(
    ProfilePasswordChanged event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(updateStatus: ProfileUpdateStatus.submitting));
    try {
      await _authRepository.updatePassword(event.newPassword);
      emit(state.copyWith(
        updateStatus: ProfileUpdateStatus.success,
        successMessage: 'Wachtwoord gewijzigd!',
      ));
      emit(state.copyWith(updateStatus: ProfileUpdateStatus.initial));
    } on AuthError catch (e) {
      emit(state.copyWith(
        updateStatus: ProfileUpdateStatus.failure,
        errorMessage: e.message,
      ));
      emit(state.copyWith(updateStatus: ProfileUpdateStatus.initial));
    }
  }

  Future<void> _onPhotoChanged(
    ProfilePhotoChanged event,
    Emitter<ProfileState> emit,
  ) async {
    if (_storageService == null) return;

    emit(state.copyWith(isUploadingPhoto: true));
    try {
      final userId = _authBloc.state.user?.uid ?? '';
      final path = 'profiles/$userId/avatar.jpg';
      final url = await _storageService.uploadImage(path, event.photo);
      await _authRepository.updateProfilePhoto(url);
      emit(state.copyWith(
        isUploadingPhoto: false,
        photoUrl: url,
        updateStatus: ProfileUpdateStatus.success,
        successMessage: 'Profielfoto gewijzigd!',
      ));
      emit(state.copyWith(updateStatus: ProfileUpdateStatus.initial));
    } catch (e) {
      emit(state.copyWith(
        isUploadingPhoto: false,
        updateStatus: ProfileUpdateStatus.failure,
        errorMessage: 'Foto uploaden mislukt. Probeer het opnieuw.',
      ));
      emit(state.copyWith(updateStatus: ProfileUpdateStatus.initial));
    }
  }
}
